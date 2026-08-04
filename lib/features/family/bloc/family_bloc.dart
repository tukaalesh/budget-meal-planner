// // ignore_for_file: prefer_const_constructors

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import '../models/family_model.dart';
// import '../../../core/services/family_api_service.dart';

// abstract class FamilyEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class FamilyInfoSubmitted extends FamilyEvent {
//   final FamilyModel family;
//   final String token;
//   FamilyInfoSubmitted({required this.family, required this.token});

//   @override
//   List<Object?> get props => [family, token];
// }

// class FamilyInfoUpdated extends FamilyEvent {
//   final FamilyModel family;
//   FamilyInfoUpdated(this.family);
//   @override
//   List<Object?> get props => [family];
// }

// abstract class FamilyState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class FamilyInitial extends FamilyState {}

// class FamilyLoading extends FamilyState {}

// class FamilySuccess extends FamilyState {
//   final String message;

//   FamilySuccess([this.message = 'تم حفظ البيانات بنجاح']);

//   @override
//   List<Object?> get props => [message];
// }

// class FamilyLoaded extends FamilyState {
//   final FamilyModel family;
//   FamilyLoaded(this.family);
//   @override
//   List<Object?> get props => [family];
// }

// class FamilyFailure extends FamilyState {
//   final String message;
//   FamilyFailure(this.message);
//   @override
//   List<Object?> get props => [message];
// }

// class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
//   FamilyBloc() : super(FamilyInitial()) {
//     on<FamilyInfoSubmitted>(_onSubmit);
//     on<FamilyInfoUpdated>(_onUpdate);
//   }

//  Future<void> _onSubmit(
//   FamilyInfoSubmitted event,
//   Emitter<FamilyState> emit,
// ) async {
//   emit(FamilyLoading());

//   final result = await FamilyApiService.saveFamilyInfo(
//     token: event.token,
//     memberCount: event.family.memberCount,
//     favoriteMeals: event.family.favoriteDishes,
//     dislikedMeals: event.family.dislikedDishes,
//     dislikedIngredients: event.family.dislikedIngredients,
//     allergicIngredients: event.family.allergies,
//     alwaysAvailableIngredients: event.family.availableBasicIngredients,
//   );

//   if (result.isSuccess) {
//     emit(FamilySuccess());
//     emit(FamilyLoaded(event.family)); // << جديد: تحديث آخر نسخة بالذاكرة
//   } else {
//     emit(FamilyFailure('حدث خطأ أثناء الأتصال حاول فيما بعد !'));
//   }
// }

//   Future<void> _onUpdate(
//     FamilyInfoUpdated event,
//     Emitter<FamilyState> emit,
//   ) async {
//     emit(FamilyLoaded(event.family));
//   }
// }
// ignore_for_file: prefer_const_constructors

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_model.dart';
import '../../../core/services/family_api_service.dart';

// ── Events ──────────────────────────────────────────────

abstract class FamilyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// إنشاء أول استبيان (POST) — بعد اللوغ ان لأول مرة
class FamilyInfoSubmitted extends FamilyEvent {
  final FamilyModel family;
  final String token;
  FamilyInfoSubmitted({required this.family, required this.token});

  @override
  List<Object?> get props => [family, token];
}

/// تعديل الاستبيان الموجود (PUT) — من صفحة البروفايل
class FamilyInfoEdited extends FamilyEvent {
  final FamilyModel family;
  final String token;
  FamilyInfoEdited({required this.family, required this.token});

  @override
  List<Object?> get props => [family, token];
}

/// جلب بيانات العائلة المحفوظة (GET)
class FamilyProfileRequested extends FamilyEvent {}

/// تحديث الحالة يدويًا بدون نداء API (نادرًا ما تحتاجه، تركناه كما كان)
class FamilyInfoUpdated extends FamilyEvent {
  final FamilyModel family;
  FamilyInfoUpdated(this.family);
  @override
  List<Object?> get props => [family];
}

// ── States ──────────────────────────────────────────────

abstract class FamilyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FamilyInitial extends FamilyState {}

class FamilyLoading extends FamilyState {}

class FamilySuccess extends FamilyState {
  final String message;
  FamilySuccess([this.message = 'تم حفظ البيانات بنجاح']);

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

// ── Bloc ────────────────────────────────────────────────

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  FamilyBloc() : super(FamilyInitial()) {
    on<FamilyInfoSubmitted>(_onSubmit);
    on<FamilyInfoEdited>(_onEdit);
    on<FamilyProfileRequested>(_onFetch);
    on<FamilyInfoUpdated>(_onUpdate);
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
      alwaysAvailableIngredients: event.family.availableBasicIngredients,
    );

    if (result.isSuccess) {
      emit(FamilySuccess());
      emit(FamilyLoaded(event.family));
    } else {
      emit(FamilyFailure('حدث خطأ أثناء الأتصال حاول فيما بعد !'));
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
      alwaysAvailableIngredients: event.family.availableBasicIngredients,
    );

    if (result.isSuccess) {
      emit(FamilySuccess('تم تعديل معلومات العائلة بنجاح'));
      emit(FamilyLoaded(event.family));
    } else {
      emit(FamilyFailure('حدث خطأ أثناء الأتصال حاول فيما بعد !'));
    }
  }

  Future<void> _onFetch(
    FamilyProfileRequested event,
    Emitter<FamilyState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(FamilyFailure('حدث خطأ ما يُرجى إعادة المحاولة'));
      return;
    }

    final result = await FamilyApiService.fetchFamilyProfile(token: token);

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
}