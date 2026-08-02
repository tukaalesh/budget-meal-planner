// ignore_for_file: prefer_const_constructors

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/meal_model.dart';

abstract class RecommendationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealAccepted extends RecommendationsEvent {
  final MealModel meal;
  MealAccepted(this.meal);
  @override
  List<Object?> get props => [meal];
}

class NewRecommendationsRequested extends RecommendationsEvent {
  final MealRequest request;
  NewRecommendationsRequested(this.request);
  @override
  List<Object?> get props => [request];
}

abstract class RecommendationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecommendationsInitial extends RecommendationsState {}
class RecommendationsRefreshing extends RecommendationsState {}

class MealAcceptedState extends RecommendationsState {
  final MealModel meal;
  final List<String> shoppingList;
  MealAcceptedState({required this.meal, required this.shoppingList});
  @override
  List<Object?> get props => [meal, shoppingList];
}

class RecommendationsBloc extends Bloc<RecommendationsEvent, RecommendationsState> {
  RecommendationsBloc() : super(RecommendationsInitial()) {
    on<MealAccepted>(_onAccept);
    on<NewRecommendationsRequested>(_onRefresh);
  }

  Future<void> _onAccept(MealAccepted event, Emitter<RecommendationsState> emit) async {
    emit(MealAcceptedState(
      meal: event.meal,
      shoppingList: event.meal.missingIngredients,
    ));
  }

  Future<void> _onRefresh(NewRecommendationsRequested event, Emitter<RecommendationsState> emit) async {
    emit(RecommendationsRefreshing());
    await Future.delayed(Duration(seconds: 2));
    emit(RecommendationsInitial());
  }
}
