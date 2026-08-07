class PlanIngredient {
  final int id;
  final String name;
  final double quantity;
  final String unit;

  const PlanIngredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory PlanIngredient.fromJson(Map<String, dynamic> json) {
    return PlanIngredient(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };
}

class PlanMeal {
  final int mealId;
  final int expandedMealId;
  final String name;
  final String prepTime;
  final String difficulty;
  final String seasonality;
  final double estimatedCost;
  final List<PlanIngredient> ingredients;

  const PlanMeal({
    required this.mealId,
    required this.expandedMealId,
    required this.name,
    required this.prepTime,
    required this.difficulty,
    required this.seasonality,
    required this.estimatedCost,
    required this.ingredients,
  });

  factory PlanMeal.fromJson(Map<String, dynamic> json) {
    return PlanMeal(
      mealId: json['meal_id'] as int,
      expandedMealId: json['expanded_meal_id'] as int,
      name: json['name'] as String,
      prepTime: json['prep_time'] as String,
      difficulty: json['difficulty'] as String,
      seasonality: json['seasonality'] as String,
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      ingredients: (json['ingredients'] as List)
          .map((e) => PlanIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'meal_id': mealId,
        'expanded_meal_id': expandedMealId,
        'name': name,
        'prep_time': prepTime,
        'difficulty': difficulty,
        'seasonality': seasonality,
        'estimated_cost': estimatedCost,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
      };
}

/// الاستجابة الكاملة لطلب POST /api/plans/generate
class GeneratedPlanModel {
  final double totalCost;
  final List<PlanMeal> meals;
  final List<int> excludedMeals;

  const GeneratedPlanModel({
    required this.totalCost,
    required this.meals,
    required this.excludedMeals,
  });

  factory GeneratedPlanModel.fromJson(Map<String, dynamic> json) {
    return GeneratedPlanModel(
      totalCost: (json['total_cost'] as num).toDouble(),
      meals: (json['meals'] as List)
          .map((e) => PlanMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
      excludedMeals: (json['excluded_meals'] as List? ?? [])
          .map((e) => e as int)
          .toList(),
    );
  }
}
