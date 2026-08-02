// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../recommendations/models/meal_model.dart';

abstract class MealHistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealHistoryAdded extends MealHistoryEvent {
  final MealModel meal;
  MealHistoryAdded(this.meal);
  @override
  List<Object?> get props => [meal];
}

class MealHistoryLoaded extends MealHistoryEvent {}

class MealHistoryCleared extends MealHistoryEvent {}

abstract class MealHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealHistoryInitial extends MealHistoryState {}

class MealHistoryLoadedState extends MealHistoryState {
  final List<MealModel> meals;
  MealHistoryLoadedState(this.meals);
  @override
  List<Object?> get props => [meals];
}

class MealHistoryBloc extends Bloc<MealHistoryEvent, MealHistoryState> {
  final List<MealModel> _history = [];

  MealHistoryBloc() : super(MealHistoryInitial()) {
    on<MealHistoryLoaded>(_onLoad);
    on<MealHistoryAdded>(_onAdd);
    on<MealHistoryCleared>(_onClear);
  }

  Future<void> _onLoad(MealHistoryLoaded event, Emitter<MealHistoryState> emit) async {
    if (_history.isEmpty) {
      _history.addAll(MealRepository.getAllMealsHistory());
    }
    emit(MealHistoryLoadedState(List.from(_history)));
  }

  Future<void> _onAdd(MealHistoryAdded event, Emitter<MealHistoryState> emit) async {
    if (!_history.any((m) => m.id == event.meal.id)) {
      _history.insert(0, event.meal);
    }
    emit(MealHistoryLoadedState(List.from(_history)));
  }

  Future<void> _onClear(MealHistoryCleared event, Emitter<MealHistoryState> emit) async {
    _history.clear();
    emit(MealHistoryLoadedState([]));
  }
}
