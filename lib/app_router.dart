// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/family/screens/family_info_screen.dart';
import 'home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/family':
        return MaterialPageRoute(builder: (_) => const FamilyInfoScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('الصفحة غير موجودة')),
          ),
        );
    }
  }
}
