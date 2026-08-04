import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sho_htghadona/features/auth/bloc/auth_cubit.dart';
import 'package:sho_htghadona/features/auth/bloc/auth_repository.dart';
import 'package:sho_htghadona/features/auth/bloc/auth_state.dart';
import 'core/theme/app_theme.dart';
import 'app_router.dart';
import 'features/family/bloc/family_bloc.dart';
import 'features/meal_request/bloc/meal_request_bloc.dart';
import 'features/meal_history/bloc/meal_history_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isNavigating = false;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            authRepository: AuthRepository(),
          )..checkAuth(),
        ),
        BlocProvider(
          create: (_) => FamilyBloc(),
        ),
        BlocProvider(
          create: (_) => MealRequestBloc(),
        ),
        BlocProvider(
          create: (_) => MealHistoryBloc(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'شو حتغدونا؟',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
        builder: (context, child) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, state) async {
              if (state is AuthSuccess) {
                final prefs = await SharedPreferences.getInstance();

                final key = 'family_completed_${state.user.id}';

                final completed = prefs.getBool(key) ?? false;

                if (completed) {
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    '/home',
                    (_) => false,
                  );
                } else {
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    '/family',
                    (_) => false,
                  );
                }
              } else if (state is AuthUnauthenticated ||
                  state is AuthLoggedOut) {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/',
                  (_) => false,
                );
              }
            },
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
