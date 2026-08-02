import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sho_htghadona/features/auth/bloc/auth_repository.dart';
import 'package:sho_htghadona/main.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());
  Future<void> checkAuth() async {
    emit(AuthUnauthenticated());
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
      emit(
        AuthFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(email: email, password: password);
      // final token = user.token;
      // print(sharedPreferences);
      // await sharedPreferences.setString('token', token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      print('token: ${user.token}');
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
    emit(AuthLoggedOut());
  }
}
