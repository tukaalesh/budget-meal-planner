import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sho_htghadona/features/auth/bloc/auth_cubit.dart';
import 'package:sho_htghadona/features/auth/bloc/auth_state.dart';
import '../models/family_model.dart';
import '../../../core/services/family_api_service.dart';

abstract class FamilyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FamilyInfoSubmitted extends FamilyEvent {
  final FamilyModel family;
  final String token;

  FamilyInfoSubmitted({
    required this.family,
    required this.token,
  });

  @override
  List<Object?> get props => [family, token];
}

class FamilyInfoEdited extends FamilyEvent {
  final FamilyModel family;
  final String token;

  FamilyInfoEdited({
    required this.family,
    required this.token,
  });

  @override
  List<Object?> get props => [family, token];
}

class FamilyProfileRequested extends FamilyEvent {}

class FamilyReset extends FamilyEvent {}

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

class FamilySuccess extends FamilyState {
  final String message;

  FamilySuccess([
    this.message = 'تم حفظ البيانات بنجاح',
  ]);

  @override
  List<Object?> get props => [message];
}

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
  final AuthCubit authCubit;

  FamilyBloc({
    required this.authCubit,
  }) : super(FamilyInitial()) {
    on<FamilyInfoSubmitted>(_onSubmit);
    on<FamilyInfoEdited>(_onEdit);
    on<FamilyProfileRequested>(_onFetch);
    on<FamilyInfoUpdated>(_onUpdate);
    on<FamilyReset>(_onReset);
  }

  Future<void> _onSubmit(
    FamilyInfoSubmitted event,
    Emitter<FamilyState> emit,
  ) async {
    emit(FamilyLoading());

    final result = await FamilyApiService.saveFamilyInfo(
      token: event.token,
      memberCount: event.family.memberCount,
      favoriteMeals: event.family.favoriteDishes,
      dislikedMeals: event.family.dislikedDishes,
      dislikedIngredients: event.family.dislikedIngredients,
      allergicIngredients: event.family.allergies,
      alwaysAvailableIngredients:
          event.family.availableBasicIngredients,
    );

    if (result.isSuccess) {
      // أهم سطر:
      // الاستبيان اكتمل، حدّث UserModel واحفظه.
      await authCubit.markFamilyProfileCompleted();

      emit(FamilySuccess());
      emit(FamilyLoaded(event.family));
    } else {
      emit(
        FamilyFailure(
          'حدث خطأ أثناء الاتصال حاول فيما بعد !',
        ),
      );
    }
  }

  Future<void> _onEdit(
    FamilyInfoEdited event,
    Emitter<FamilyState> emit,
  ) async {
    emit(FamilyLoading());

    final result = await FamilyApiService.updateFamilyInfo(
      token: event.token,
      memberCount: event.family.memberCount,
      favoriteMeals: event.family.favoriteDishes,
      dislikedMeals: event.family.dislikedDishes,
      dislikedIngredients: event.family.dislikedIngredients,
      allergicIngredients: event.family.allergies,
      alwaysAvailableIngredients:
          event.family.availableBasicIngredients,
    );

    if (result.isSuccess) {
      emit(
        FamilySuccess(
          'تم تعديل معلومات العائلة بنجاح',
        ),
      );

      emit(FamilyLoaded(event.family));
    } else {
      emit(
        FamilyFailure(
          'حدث خطأ أثناء الاتصال حاول فيما بعد !',
        ),
      );
    }
  }

  Future<void> _onFetch(
    FamilyProfileRequested event,
    Emitter<FamilyState> emit,
  ) async {
    final currentState = authCubit.state;

    if (currentState is! AuthSuccess) {
      emit(
        FamilyFailure(
          'المستخدم غير مسجل الدخول',
        ),
      );
      return;
    }

    final token = currentState.user.token;

    final result = await FamilyApiService.fetchFamilyProfile(
      token: token,
    );

    if (result.isSuccess) {
      emit(FamilyLoaded(result.data!));
    } else {
      emit(FamilyFailure(result.error!));
    }
  }

  Future<void> _onUpdate(
    FamilyInfoUpdated event,
    Emitter<FamilyState> emit,
  ) async {
    emit(FamilyLoaded(event.family));
  }

  void _onReset(
    FamilyReset event,
    Emitter<FamilyState> emit,
  ) {
    emit(FamilyInitial());
  }
}