import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          create: (context) => FamilyBloc(
            authCubit: context.read<AuthCubit>(),
          ),
        ),
        BlocProvider(
          create: (_) => MealRequestBloc(),
        ),
        BlocProvider(
          create: (context) =>
              MealHistoryBloc(authCubit: context.read<AuthCubit>()),
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
            listener: (context, state) {
              if (state is AuthSuccess) {
                if (state.user.familyProfileCompleted) {
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    '/home',
                    (route) => false,
                  );
                } else {
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    '/family',
                    (route) => false,
                  );
                }
              } else if (state is AuthUnauthenticated ||
                  state is AuthLoggedOut) {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
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
