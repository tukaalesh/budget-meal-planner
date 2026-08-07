// نقطة دخول منفصلة للمعاينة فقط - لا تؤثر على main.dart الحقيقي.
// للتشغيل: flutter run -t lib/dev_preview_main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/meal_request/models/meal_request_model.dart';
import 'features/meal_request/screens/meal_request_screen.dart';
import 'features/recommendations/bloc/recommendations_bloc.dart';
import 'features/recommendations/models/meal_model.dart';
import 'features/recommendations/models/shopping_list_model.dart';
import 'features/recommendations/screens/meal_detail_screen.dart';
import 'features/recommendations/screens/recommendations_screen.dart';
import 'features/recommendations/screens/shopping_list_screen.dart';
import 'features/meal_history/bloc/meal_history_bloc.dart';
import 'features/meal_history/screens/meal_history_screen.dart';

void main() {
  runApp(const _PreviewApp());
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'معاينة الواجهات',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: _PreviewMenu(),
      ),
    );
  }
}

// ==================== بيانات وهمية (Mock Data) ====================
// نفس الأمثلة اللي أرسلتها سابقًا بالضبط، حتى تكون المعاينة واقعية.

MealRequestModel get _mockRequest => const MealRequestModel(
      budget: 200000,
      servings: 1,
      numberOfMeals: 7,
      daysPerMeal: 2,
      prepTime: PrepTime.medium,
      availableIngredients: [
        AvailableIngredient(name: 'رز', unit: 'غرام', quantity: 1000),
        AvailableIngredient(name: 'بطاطا', unit: 'غرام', quantity: 500),
      ],
    );

GeneratedPlanModel get _mockPlan => GeneratedPlanModel.fromJson({
      "total_cost": 132000,
      "meals": [
        {
          "meal_id": 94,
          "expanded_meal_id": 758,
          "name": "مقلوبة",
          "prep_time": "متوسط",
          "difficulty": "متوسط",
          "seasonality": "الصيف",
          "estimated_cost": 34000,
          "ingredients": [
            {"id": 37, "name": "بيتنجان", "quantity": 500, "unit": "غرام"},
            {"id": 2, "name": "لحم مفروم", "quantity": 126, "unit": "غرام"},
            {"id": 66, "name": "زيت نباتي", "quantity": 200, "unit": "غرام"},
            {"id": 14, "name": "رز", "quantity": 150, "unit": "غرام"},
            {"id": 69, "name": "مكسرات", "quantity": 26, "unit": "غرام"},
          ],
        },
        {
          "meal_id": 21,
          "expanded_meal_id": 270,
          "name": "كباب هندي",
          "prep_time": "متوسط",
          "difficulty": "متوسط",
          "seasonality": "الصيف",
          "estimated_cost": 98000,
          "ingredients": [
            {"id": 3, "name": "لحم ناعم", "quantity": 500, "unit": "غرام"},
            {"id": 29, "name": "بصل", "quantity": 150, "unit": "غرام"},
            {"id": 30, "name": "بندورة", "quantity": 500, "unit": "غرام"},
            {"id": 32, "name": "فليفلة خضرا", "quantity": 226, "unit": "غرام"},
            {"id": 14, "name": "رز", "quantity": 100, "unit": "غرام"},
            {"id": 13, "name": "شعيرية", "quantity": 26, "unit": "غرام"},
          ],
        },
      ],
      "excluded_meals": [63, 10],
    });

AcceptPlanResponseModel get _mockAcceptResponse =>
    AcceptPlanResponseModel.fromJson({
      "message": "تم قبول الخطة بنجاح.",
      "plan_id": 2,
      "shopping_list": [
        {"ingredient": "بيتنجان", "required_quantity": 500, "available_quantity": 0, "unit": "غرام", "estimated_price": 3500},
        {"ingredient": "لحم مفروم", "required_quantity": 126, "available_quantity": 0, "unit": "غرام", "estimated_price": 22050},
        {"ingredient": "زيت نباتي", "required_quantity": 200, "available_quantity": 0, "unit": "غرام", "estimated_price": 3600},
        {"ingredient": "مكسرات", "required_quantity": 26, "available_quantity": 0, "unit": "غرام", "estimated_price": 3900},
        {"ingredient": "لحم ناعم", "required_quantity": 500, "available_quantity": 0, "unit": "غرام", "estimated_price": 90000},
        {"ingredient": "بصل", "required_quantity": 150, "available_quantity": 0, "unit": "غرام", "estimated_price": 900},
        {"ingredient": "بندورة", "required_quantity": 500, "available_quantity": 0, "unit": "غرام", "estimated_price": 4500},
        {"ingredient": "فليفلة خضرا", "required_quantity": 226, "available_quantity": 0, "unit": "غرام", "estimated_price": 2034},
        {"ingredient": "شعيرية", "required_quantity": 26, "available_quantity": 0, "unit": "غرام", "estimated_price": 312},
      ],
    });

// ==================== قائمة المعاينة ====================

class _PreviewMenu extends StatelessWidget {
  const _PreviewMenu();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('معاينة الواجهات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PreviewTile(
            title: 'طلب خطة وجبات',
            subtitle: 'يحتاج باك اند شغّال محليًا على 127.0.0.1:8000',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MealRequestScreen()),
            ),
          ),
          _PreviewTile(
            title: 'الخطة المقترحة',
            subtitle: 'ببيانات وهمية - لا يحتاج شبكة',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecommendationsScreen(
                  originalRequest: _mockRequest,
                  plan: _mockPlan,
                ),
              ),
            ),
          ),
          _PreviewTile(
            title: 'تفاصيل وجبة',
            subtitle: 'ببيانات وهمية - لا يحتاج شبكة',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => RecommendationsBloc(
                    requestModel: _mockRequest,
                    initialPlan: _mockPlan,
                  ),
                  child: MealDetailScreen(meal: _mockPlan.meals.first),
                ),
              ),
            ),
          ),
          _PreviewTile(
            title: 'قائمة التسوق',
            subtitle: 'ببيانات وهمية - لا يحتاج شبكة',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShoppingListScreen(response: _mockAcceptResponse),
              ),
            ),
          ),
          _PreviewTile(
            title: 'سجل الخطط',
            subtitle: 'يحتاج توكن حقيقي وباك اند شغّال (بدونه ستظهر حالة خطأ)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => MealHistoryBloc(authToken: null),
                  child: const MealHistoryScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PreviewTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
