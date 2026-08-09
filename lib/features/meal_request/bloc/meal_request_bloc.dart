import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/plan_api_service.dart';
import '../../recommendations/models/meal_model.dart';
import '../models/meal_request_model.dart';


abstract class MealRequestEvent extends Equatable {
  const MealRequestEvent();
  @override
  List<Object?> get props => [];
}

class BudgetChanged extends MealRequestEvent {
  final String value;
  const BudgetChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class ServingsIncremented extends MealRequestEvent {
  const ServingsIncremented();
}

class ServingsDecremented extends MealRequestEvent {
  const ServingsDecremented();
}

class MealsCountIncremented extends MealRequestEvent {
  const MealsCountIncremented();
}

class MealsCountDecremented extends MealRequestEvent {
  const MealsCountDecremented();
}

class SpreadOverTwoDaysToggled extends MealRequestEvent {
  final bool value;
  const SpreadOverTwoDaysToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class PrepTimeSelected extends MealRequestEvent {
  final PrepTime value;
  const PrepTimeSelected(this.value);
  @override
  List<Object?> get props => [value];
}

class IngredientAdded extends MealRequestEvent {
  final AvailableIngredient ingredient;
  const IngredientAdded(this.ingredient);
  @override
  List<Object?> get props => [ingredient];
}

class IngredientRemoved extends MealRequestEvent {
  final int index;
  const IngredientRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class IngredientQuantityChanged extends MealRequestEvent {
  final int index;
  final double quantity;
  const IngredientQuantityChanged(this.index, this.quantity);
  @override
  List<Object?> get props => [index, quantity];
}

class PlanGenerationSubmitted extends MealRequestEvent {
  const PlanGenerationSubmitted();
}

// ==================== State ====================

enum SubmissionStatus { initial, loading, success, failure }

class MealRequestState extends Equatable {
  final double? budget;
  final bool budgetTouched;
  final int servings;
  final int numberOfMeals;
  final bool spreadOverTwoDays;
  final PrepTime prepTime;
  final List<AvailableIngredient> availableIngredients;
  final SubmissionStatus status;
  final String? errorMessage;
  final GeneratedPlanModel? generatedPlan;

  const MealRequestState({
    this.budget,
    this.budgetTouched = false,
    this.servings = 1,
    this.numberOfMeals = 1,
    this.spreadOverTwoDays = false,
    this.prepTime = PrepTime.medium,
    this.availableIngredients = const [],
    this.status = SubmissionStatus.initial,
    this.errorMessage,
    this.generatedPlan,
  });

  bool get isBudgetValid => budget != null && budget! >= 0;
  int get daysPerMeal => spreadOverTwoDays ? 2 : 1;

  MealRequestState copyWith({
    double? budget,
    bool clearBudget = false,
    bool? budgetTouched,
    int? servings,
    int? numberOfMeals,
    bool? spreadOverTwoDays,
    PrepTime? prepTime,
    List<AvailableIngredient>? availableIngredients,
    SubmissionStatus? status,
    String? errorMessage,
    GeneratedPlanModel? generatedPlan,
  }) {
    return MealRequestState(
      budget: clearBudget ? null : (budget ?? this.budget),
      budgetTouched: budgetTouched ?? this.budgetTouched,
      servings: servings ?? this.servings,
      numberOfMeals: numberOfMeals ?? this.numberOfMeals,
      spreadOverTwoDays: spreadOverTwoDays ?? this.spreadOverTwoDays,
      prepTime: prepTime ?? this.prepTime,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      status: status ?? this.status,
      errorMessage: errorMessage,
      generatedPlan: generatedPlan ?? this.generatedPlan,
    );
  }

  @override
  List<Object?> get props => [
        budget,
        budgetTouched,
        servings,
        numberOfMeals,
        spreadOverTwoDays,
        prepTime,
        availableIngredients,
        status,
        errorMessage,
        generatedPlan,
      ];
}

// ==================== Bloc ====================

class MealRequestBloc extends Bloc<MealRequestEvent, MealRequestState> {
  static const int minServings = 1;
  static const int maxServings = 30;
  static const int minMeals = 1;
  static const int maxMeals = 7;

  /// توكن المصادقة. مرّره عند إنشاء الـ Bloc (مثلًا من AuthCubit/AuthRepository).
  /// TODO: اربطه بمصدر التوكن الحقيقي عندك، مثال:
  /// MealRequestBloc(authToken: context.read<AuthCubit>().state.token)
  final String? authToken;

  MealRequestBloc({this.authToken}) : super(const MealRequestState()) {
    on<BudgetChanged>(_onBudgetChanged);
    on<ServingsIncremented>((event, emit) {
      if (state.servings < maxServings) {
        emit(state.copyWith(servings: state.servings + 1));
      }
    });
    on<ServingsDecremented>((event, emit) {
      if (state.servings > minServings) {
        emit(state.copyWith(servings: state.servings - 1));
      }
    });
    on<MealsCountIncremented>((event, emit) {
      if (state.numberOfMeals < maxMeals) {
        emit(state.copyWith(numberOfMeals: state.numberOfMeals + 1));
      }
    });
    on<MealsCountDecremented>((event, emit) {
      if (state.numberOfMeals > minMeals) {
        emit(state.copyWith(numberOfMeals: state.numberOfMeals - 1));
      }
    });
    on<SpreadOverTwoDaysToggled>((event, emit) {
      emit(state.copyWith(spreadOverTwoDays: event.value));
    });
    on<PrepTimeSelected>((event, emit) {
      emit(state.copyWith(prepTime: event.value));
    });
    on<IngredientAdded>((event, emit) {
      final existingIndex = state.availableIngredients.indexWhere(
        (i) => i.name.trim() == event.ingredient.name.trim(),
      );
      if (existingIndex != -1) {
        // نفس المكوّن مضاف سابقًا: ندمج الكميات بدل إضافة سطر مكرر.
        final updated = [...state.availableIngredients];
        final existing = updated[existingIndex];
        updated[existingIndex] = existing.copyWith(
          quantity: existing.quantity + event.ingredient.quantity,
        );
        emit(state.copyWith(availableIngredients: updated));
      } else {
        emit(state.copyWith(
          availableIngredients: [...state.availableIngredients, event.ingredient],
        ));
      }
    });
    on<IngredientRemoved>((event, emit) {
      final updated = [...state.availableIngredients]..removeAt(event.index);
      emit(state.copyWith(availableIngredients: updated));
    });
    on<IngredientQuantityChanged>((event, emit) {
      final updated = [...state.availableIngredients];
      updated[event.index] =
          updated[event.index].copyWith(quantity: event.quantity);
      emit(state.copyWith(availableIngredients: updated));
    });
    on<PlanGenerationSubmitted>(_onSubmitted);
  }

  void _onBudgetChanged(BudgetChanged event, Emitter<MealRequestState> emit) {
    if (event.value.trim().isEmpty) {
      emit(state.copyWith(clearBudget: true));
      return;
    }
    final parsed = double.tryParse(event.value);
    if (parsed == null) return;
    emit(state.copyWith(budget: parsed));
  }

  Future<void> _onSubmitted(
    PlanGenerationSubmitted event,
    Emitter<MealRequestState> emit,
  ) async {
    emit(state.copyWith(budgetTouched: true));
    if (!state.isBudgetValid) return;

    if (authToken == null || authToken!.isEmpty) {
      emit(state.copyWith(
        status: SubmissionStatus.failure,
        errorMessage: 'يجب تسجيل الدخول أولاً',
      ));
      return;
    }

    emit(state.copyWith(status: SubmissionStatus.loading));

    final requestModel = MealRequestModel(
      budget: state.budget!,
      servings: state.servings,
      numberOfMeals: state.numberOfMeals,
      daysPerMeal: state.daysPerMeal,
      prepTime: state.prepTime,
      availableIngredients: state.availableIngredients,
    );

    final result = await PlansApiService.generatePlan(
      body: requestModel.toJson(),
      token: authToken!,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        status: SubmissionStatus.success,
        generatedPlan: result.data,
      ));
    } else {
      emit(state.copyWith(
        status: SubmissionStatus.failure,
        errorMessage: result.error ?? 'حدث خطأ غير متوقع',
      ));
    }
  }
}
