import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/plan_api_service.dart';
import '../models/plan_history_model.dart';

// ==================== Events ====================

abstract class MealHistoryEvent extends Equatable {
  const MealHistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryRequested extends MealHistoryEvent {
  const HistoryRequested();
}

class PlanDetailRequested extends MealHistoryEvent {
  final int planId;
  const PlanDetailRequested(this.planId);
  @override
  List<Object?> get props => [planId];
}

// ==================== State ====================

enum AsyncStatus { idle, loading, success, failure }

class MealHistoryState extends Equatable {
  final AsyncStatus listStatus;
  final List<PlanSummary> plans;
  final String? listErrorMessage;

  final AsyncStatus detailStatus;
  final PlanDetail? selectedPlan;
  final String? detailErrorMessage;

  const MealHistoryState({
    this.listStatus = AsyncStatus.idle,
    this.plans = const [],
    this.listErrorMessage,
    this.detailStatus = AsyncStatus.idle,
    this.selectedPlan,
    this.detailErrorMessage,
  });

  MealHistoryState copyWith({
    AsyncStatus? listStatus,
    List<PlanSummary>? plans,
    String? listErrorMessage,
    AsyncStatus? detailStatus,
    PlanDetail? selectedPlan,
    String? detailErrorMessage,
  }) {
    return MealHistoryState(
      listStatus: listStatus ?? this.listStatus,
      plans: plans ?? this.plans,
      listErrorMessage: listErrorMessage,
      detailStatus: detailStatus ?? this.detailStatus,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      detailErrorMessage: detailErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        listStatus,
        plans,
        listErrorMessage,
        detailStatus,
        selectedPlan,
        detailErrorMessage,
      ];
}

// ==================== Bloc ====================

class MealHistoryBloc extends Bloc<MealHistoryEvent, MealHistoryState> {
  /// TODO: مرّر التوكن الحقيقي عند إنشاء الـ Bloc (نفس نمط باقي الـ Blocs).
  final String? authToken;

  MealHistoryBloc({this.authToken}) : super(const MealHistoryState()) {
    on<HistoryRequested>(_onHistoryRequested);
    on<PlanDetailRequested>(_onPlanDetailRequested);
  }

  Future<void> _onHistoryRequested(
    HistoryRequested event,
    Emitter<MealHistoryState> emit,
  ) async {
    if (authToken == null || authToken!.isEmpty) {
      emit(state.copyWith(
        listStatus: AsyncStatus.failure,
        listErrorMessage: 'يجب تسجيل الدخول أولاً',
      ));
      return;
    }

    emit(state.copyWith(listStatus: AsyncStatus.loading));

    final result = await PlansApiService.getPlans(token: authToken!);

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        listStatus: AsyncStatus.success,
        plans: result.data,
      ));
    } else {
      emit(state.copyWith(
        listStatus: AsyncStatus.failure,
        listErrorMessage: result.error ?? 'حدث خطأ غير متوقع',
      ));
    }
  }

  Future<void> _onPlanDetailRequested(
    PlanDetailRequested event,
    Emitter<MealHistoryState> emit,
  ) async {
    if (authToken == null || authToken!.isEmpty) {
      emit(state.copyWith(
        detailStatus: AsyncStatus.failure,
        detailErrorMessage: 'يجب تسجيل الدخول أولاً',
      ));
      return;
    }

    emit(state.copyWith(detailStatus: AsyncStatus.loading));

    final result = await PlansApiService.getPlanDetail(
      planId: event.planId,
      token: authToken!,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        detailStatus: AsyncStatus.success,
        selectedPlan: result.data,
      ));
    } else {
      emit(state.copyWith(
        detailStatus: AsyncStatus.failure,
        detailErrorMessage: result.error ?? 'حدث خطأ غير متوقع',
      ));
    }
  }
}
