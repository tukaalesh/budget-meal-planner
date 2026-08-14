import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/plan_api_service.dart';
import '../../meal_request/models/meal_request_model.dart';
import '../models/meal_model.dart';
import '../models/shopping_list_model.dart';

// ==================== Events ====================

abstract class RecommendationsEvent extends Equatable {
  const RecommendationsEvent();
  @override
  List<Object?> get props => [];
}

class MealLikeToggled extends RecommendationsEvent {
  final int mealId;
  const MealLikeToggled(this.mealId);
  @override
  List<Object?> get props => [mealId];
}

class PlanRegenerationRequested extends RecommendationsEvent {
  const PlanRegenerationRequested();
}

class PlanAcceptRequested extends RecommendationsEvent {
  const PlanAcceptRequested();
}

// ==================== State ====================

enum AsyncStatus { idle, loading, success, failure }

class RecommendationsState extends Equatable {
  /// معلومات الطلب الأصلي (الميزانية، عدد الأشخاص...) - تبقى ثابتة
  /// وتُستخدم في كل من إعادة التوليد وطلب القبول.
  final MealRequestModel requestModel;

  /// الخطة المعروضة حاليًا.
  final GeneratedPlanModel plan;

  /// معرّفات الوجبات التي أعجبت المستخدم بالجولة الحالية فقط (meal_id).
  final Set<int> likedMealIds;

  /// معرّفات كل الوجبات التي لم تعجب المستخدم عبر كل جولات إعادة الطلب
  /// (تراكمية) - حتى لا تُقترح عليه مرة ثانية أبدًا.
  final Set<int> excludedMealIds;

  final AsyncStatus regenerateStatus;
  final AsyncStatus acceptStatus;
  final String? errorMessage;
  final AcceptPlanResponseModel? acceptResponse;

  const RecommendationsState({
    required this.requestModel,
    required this.plan,
    this.likedMealIds = const {},
    this.excludedMealIds = const {},
    this.regenerateStatus = AsyncStatus.idle,
    this.acceptStatus = AsyncStatus.idle,
    this.errorMessage,
    this.acceptResponse,
  });

  bool isLiked(int mealId) => likedMealIds.contains(mealId);

  RecommendationsState copyWith({
    GeneratedPlanModel? plan,
    Set<int>? likedMealIds,
    Set<int>? excludedMealIds,
    AsyncStatus? regenerateStatus,
    AsyncStatus? acceptStatus,
    String? errorMessage,
    AcceptPlanResponseModel? acceptResponse,
  }) {
    return RecommendationsState(
      requestModel: requestModel,
      plan: plan ?? this.plan,
      likedMealIds: likedMealIds ?? this.likedMealIds,
      excludedMealIds: excludedMealIds ?? this.excludedMealIds,
      regenerateStatus: regenerateStatus ?? this.regenerateStatus,
      acceptStatus: acceptStatus ?? this.acceptStatus,
      errorMessage: errorMessage,
      acceptResponse: acceptResponse ?? this.acceptResponse,
    );
  }

  @override
  List<Object?> get props => [
        requestModel,
        plan,
        likedMealIds,
        excludedMealIds,
        regenerateStatus,
        acceptStatus,
        errorMessage,
        acceptResponse,
      ];
}

// ==================== Bloc ====================

class RecommendationsBloc
    extends Bloc<RecommendationsEvent, RecommendationsState> {
  /// TODO: مرّر التوكن الحقيقي عند إنشاء الـ Bloc، مثل ما فعلنا في
  /// MealRequestBloc (من AuthCubit/AuthRepository).
  final String? authToken;

  RecommendationsBloc({
    required MealRequestModel requestModel,
    required GeneratedPlanModel initialPlan,
    this.authToken,
  }) : super(RecommendationsState(requestModel: requestModel, plan: initialPlan)) {
    on<MealLikeToggled>(_onMealLikeToggled);
    on<PlanRegenerationRequested>(_onRegenerateRequested);
    on<PlanAcceptRequested>(_onAcceptRequested);
  }

  void _onMealLikeToggled(
      MealLikeToggled event, Emitter<RecommendationsState> emit) {
    final updated = {...state.likedMealIds};
    if (updated.contains(event.mealId)) {
      updated.remove(event.mealId);
    } else {
      updated.add(event.mealId);
    }
    emit(state.copyWith(likedMealIds: updated));
  }

  Future<void> _onRegenerateRequested(
    PlanRegenerationRequested event,
    Emitter<RecommendationsState> emit,
  ) async {
    if (authToken == null || authToken!.isEmpty) {
      emit(state.copyWith(
        regenerateStatus: AsyncStatus.failure,
        errorMessage: 'يجب تسجيل الدخول أولاً',
      ));
      return;
    }

    emit(state.copyWith(regenerateStatus: AsyncStatus.loading));

    // نبني قائمة الوجبات المطلوبة (المُعجب بها) من الخطة الحالية.
    final likedMeals = state.plan.meals
        .where((m) => state.likedMealIds.contains(m.mealId))
        .map((m) => RequiredMeal(
              mealId: m.mealId,
              expandedMealId: m.expandedMealId,
            ))
        .toList();

    // الوجبات غير المُعجب بها بهذه الجولة تحديدًا...
    final newlyExcludedIds = state.plan.meals
        .where((m) => !state.likedMealIds.contains(m.mealId))
        .map((m) => m.mealId)
        .toSet();

    // ...تُضاف إلى كل الاستبعادات المتراكمة من الجولات السابقة، حتى لا
    // تُقترح أي وجبة رُفضت سابقًا مرة أخرى بأي جولة قادمة.
    final cumulativeExcludedIds = {
      ...state.excludedMealIds,
      ...newlyExcludedIds,
    };

    final requestForRegeneration = MealRequestModel(
      budget: state.requestModel.budget,
      servings: state.requestModel.servings,
      numberOfMeals: state.requestModel.numberOfMeals,
      daysPerMeal: state.requestModel.daysPerMeal,
      prepTime: state.requestModel.prepTime,
      availableIngredients: state.requestModel.availableIngredients,
      requiredMeals: likedMeals,
      excludedMeals: cumulativeExcludedIds.toList(),
    );

    final result = await PlansApiService.generatePlan(
      body: requestForRegeneration.toJson(),
      token: authToken!,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        regenerateStatus: AsyncStatus.success,
        plan: result.data,
        // نُبقي likedMealIds كما هي (بدون تصفير) لأن هذه الوجبات أُرسلت
        // كـ required_meals، فهي مضمونة الظهور بالخطة الجديدة، ويجب أن
        // يظل قلبها أحمر تلقائيًا حتى لا يُضطر المستخدم لتحديدها من جديد
        // كل مرة. يبقى بإمكانه إزالة الإعجاب عنها يدويًا لو غيّر رأيه.
        excludedMealIds: cumulativeExcludedIds,
      ));
    } else {
      emit(state.copyWith(
        regenerateStatus: AsyncStatus.failure,
        errorMessage: result.error ?? 'حدث خطأ غير متوقع',
      ));
    }
  }

  Future<void> _onAcceptRequested(
    PlanAcceptRequested event,
    Emitter<RecommendationsState> emit,
  ) async {
    if (authToken == null || authToken!.isEmpty) {
      emit(state.copyWith(
        acceptStatus: AsyncStatus.failure,
        errorMessage: 'يجب تسجيل الدخول أولاً',
      ));
      return;
    }

    emit(state.copyWith(acceptStatus: AsyncStatus.loading));

    final body = {
      'budget': state.requestModel.budget,
      'servings': state.requestModel.servings,
      'number_of_meals': state.requestModel.numberOfMeals,
      'days_per_meal': state.requestModel.daysPerMeal,
      'prep_time': state.requestModel.prepTime.label,
      'available_ingredients': state.requestModel.availableIngredients
          .map((e) => e.toJson())
          .toList(),
      'total_cost': state.plan.totalCost,
      'meals': state.plan.meals.map((m) => m.toJson()).toList(),
    };

    final result = await PlansApiService.acceptPlan(
      body: body,
      token: authToken!,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        acceptStatus: AsyncStatus.success,
        acceptResponse: result.data,
      ));
    } else {
      emit(state.copyWith(
        acceptStatus: AsyncStatus.failure,
        errorMessage: result.error ?? 'حدث خطأ غير متوقع',
      ));
    }
  }
}
