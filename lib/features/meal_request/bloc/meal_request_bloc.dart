// ignore_for_file: prefer_const_constructors

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../recommendations/models/meal_model.dart';

abstract class MealRequestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealRequestSubmitted extends MealRequestEvent {
  final MealRequest request;
  MealRequestSubmitted(this.request);
  @override
  List<Object?> get props => [request];
}

class MealRequestReset extends MealRequestEvent {}

abstract class MealRequestState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealRequestInitial extends MealRequestState {}
class MealRequestLoading extends MealRequestState {}

class MealRequestSuccess extends MealRequestState {
  final MealRequest request;
  final List<MealModel> recommendations;
  MealRequestSuccess({required this.request, required this.recommendations});
  @override
  List<Object?> get props => [request, recommendations];
}

class MealRequestFailure extends MealRequestState {
  final String message;
  MealRequestFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class MealRequestBloc extends Bloc<MealRequestEvent, MealRequestState> {
  MealRequestBloc() : super(MealRequestInitial()) {
    on<MealRequestSubmitted>(_onSubmit);
    on<MealRequestReset>(_onReset);
  }

  Future<void> _onSubmit(MealRequestSubmitted event, Emitter<MealRequestState> emit) async {
    emit(MealRequestLoading());
    await Future.delayed(Duration(seconds: 2));
    final recommendations = MealRepository.getRecommendations(event.request);
    if (recommendations.isEmpty) {
      emit(MealRequestFailure('لم نجد وجبات مناسبة لميزانيتك ووقتك. حاول تعديل المعطيات.'));
    } else {
      emit(MealRequestSuccess(request: event.request, recommendations: recommendations));
    }
  }

  Future<void> _onReset(MealRequestReset event, Emitter<MealRequestState> emit) async {
    emit(MealRequestInitial());
  }
}
