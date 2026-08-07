/// دالة تخمّن وحدة القياس المناسبة بناءً على اسم المكوّن، بما أن خدمة
/// البحث الحالية ترجع أسماء نصية فقط بدون وحدة. عدّل هذه القائمة أو استبدلها
/// إذا أضاف الباك اند حقل unit إلى نتائج البحث مستقبلًا.
const _kPieceUnitKeywords = ['بيض'];

String inferUnitForIngredientName(String name) {
  for (final keyword in _kPieceUnitKeywords) {
    if (name.contains(keyword)) return 'حبة';
  }
  return 'غرام';
}

/// المكون المتاح لدى المستخدم (اسم + كمية)
/// الوحدة (غرام/حبة) تُستنتج تلقائيًا عبر [inferUnitForIngredientName]
/// لأن خدمة البحث الحالية لا ترجعها.
class AvailableIngredient {
  final String name;
  final String unit; // "غرام" أو "حبة" ...
  final double quantity;

  const AvailableIngredient({
    required this.name,
    required this.unit,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
  };

  AvailableIngredient copyWith({double? quantity}) => AvailableIngredient(
    name: name,
    unit: unit,
    quantity: quantity ?? this.quantity,
  );
}

/// نتيجة بحث عن مكوّن (تُستخدم في حقل البحث/الاقتراح فقط،
/// وليست جزءًا من الـ JSON المُرسل). الوحدة مُستنتَجة من الاسم حاليًا.
class IngredientOption {
  final String name;
  final String unit;

  IngredientOption({required this.name})
      : unit = inferUnitForIngredientName(name);

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is IngredientOption && other.name == name);

  @override
  int get hashCode => name.hashCode;
}

/// وجبة مطلوبة (تُستخدم عند إعادة توليد خطة بعد إعجاب المستخدم ببعض
/// الوجبات - غير مستخدمة في هذه الواجهة حاليًا لكن موجودة لاكتمال النموذج).
class RequiredMeal {
  final int mealId;
  final int expandedMealId;

  const RequiredMeal({
    required this.mealId,
    required this.expandedMealId,
  });

  Map<String, dynamic> toJson() => {
    'meal_id': mealId,
    'expanded_meal_id': expandedMealId,
  };
}

/// وقت التحضير المتاح اختياره من القائمة المنسدلة.
enum PrepTime {
  low('قليل'),
  medium('متوسط'),
  high('طويل');

  final String label;
  const PrepTime(this.label);
}

class MealRequestModel {
  final double budget;
  final int servings;
  final int numberOfMeals;
  final int daysPerMeal; // 1 أو 2
  final PrepTime prepTime;
  final List<AvailableIngredient> availableIngredients;
  final List<RequiredMeal> requiredMeals;
  final List<int> excludedMeals;

  const MealRequestModel({
    required this.budget,
    required this.servings,
    required this.numberOfMeals,
    required this.daysPerMeal,
    required this.prepTime,
    this.availableIngredients = const [],
    this.requiredMeals = const [],
    this.excludedMeals = const [],
  });

  Map<String, dynamic> toJson() => {
    'budget': budget,
    'servings': servings,
    'number_of_meals': numberOfMeals,
    'days_per_meal': daysPerMeal,
    'prep_time': prepTime.label,
    'available_ingredients':
    availableIngredients.map((e) => e.toJson()).toList(),
    'required_meals': requiredMeals.map((e) => e.toJson()).toList(),
    'excluded_meals': excludedMeals,
  };
}
