import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sho_htghadona/features/auth/bloc/auth_repository.dart';
import 'package:sho_htghadona/features/auth/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  static const _userKey = 'auth_user';

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final user = UserModel.fromJson(jsonDecode(userJson));
        //print("CHECK AUTH ID = ${user.id}");
        emit(AuthSuccess(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthRegisterSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(email: email, password: password);
      // print("LOGIN ID = ${user.id}");
      final prefs = await SharedPreferences.getInstance();
      //ضفت هاد السطؤ
      await prefs.setString('user_id', user.id);
      await prefs.setString('token', user.token);

      await _saveUser(user);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    final currentState = state;
    if (currentState is AuthSuccess) {
      try {
        await authRepository.logout(currentState.user.token);
      } catch (_) {}
    }
    await _clearUser();
    emit(AuthLoggedOut());
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
