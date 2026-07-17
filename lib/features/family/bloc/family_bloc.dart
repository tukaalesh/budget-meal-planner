// ignore_for_file: prefer_const_constructors

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/family_model.dart';

abstract class FamilyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FamilyInfoSubmitted extends FamilyEvent {
  final FamilyModel family;
  FamilyInfoSubmitted(this.family);
  @override
  List<Object?> get props => [family];
}

class FamilyInfoUpdated extends FamilyEvent {
  final FamilyModel family;
  FamilyInfoUpdated(this.family);
  @override
  List<Object?> get props => [family];
}

abstract class FamilyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FamilyInitial extends FamilyState {}
class FamilyLoading extends FamilyState {}

class FamilyLoaded extends FamilyState {
  final FamilyModel family;
  FamilyLoaded(this.family);
  @override
  List<Object?> get props => [family];
}

class FamilyFailure extends FamilyState {
  final String message;
  FamilyFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  FamilyBloc() : super(FamilyInitial()) {
    on<FamilyInfoSubmitted>(_onSubmit);
    on<FamilyInfoUpdated>(_onUpdate);
  }

  Future<void> _onSubmit(FamilyInfoSubmitted event, Emitter<FamilyState> emit) async {
    emit(FamilyLoading());
    await Future.delayed(Duration(milliseconds: 600));
    emit(FamilyLoaded(event.family));
  }

  Future<void> _onUpdate(FamilyInfoUpdated event, Emitter<FamilyState> emit) async {
    emit(FamilyLoaded(event.family));
  }
}
