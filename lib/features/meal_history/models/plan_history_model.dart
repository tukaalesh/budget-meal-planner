/// ملخص خطة كما يظهر في قائمة GET /api/plans
class PlanSummary {
  final int id;
  final DateTime createdAt;
  final double estimatedCost;
  final double budget;
  final int numberOfMeals;
  final int daysPerMeal;
  final int servings;
  final String prepTime;

  const PlanSummary({
    required this.id,
    required this.createdAt,
    required this.estimatedCost,
    required this.budget,
    required this.numberOfMeals,
    required this.daysPerMeal,
    required this.servings,
    required this.prepTime,
  });

  factory PlanSummary.fromJson(Map<String, dynamic> json) {
    return PlanSummary(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      budget: (json['budget'] as num).toDouble(),
      numberOfMeals: json['number_of_meals'] as int,
      daysPerMeal: json['days_per_meal'] as int,
      servings: json['servings'] as int,
      prepTime: json['prep_time'] as String,
    );
  }
}

class HistoryIngredient {
  final int id;
  final String name;
  final double quantity;
  final String unit;

  const HistoryIngredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory HistoryIngredient.fromJson(Map<String, dynamic> json) {
    return HistoryIngredient(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}

class HistoryMeal {
  final int day;
  final int mealId;
  final String name;
  final double estimatedCost;
  final List<HistoryIngredient> ingredients;

  const HistoryMeal({
    required this.day,
    required this.mealId,
    required this.name,
    required this.estimatedCost,
    required this.ingredients,
  });

  factory HistoryMeal.fromJson(Map<String, dynamic> json) {
    return HistoryMeal(
      day: json['day'] as int,
      mealId: json['meal_id'] as int,
      name: json['name'] as String,
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      ingredients: (json['ingredients'] as List)
          .map((e) => HistoryIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HistoryShoppingItem {
  final int ingredientId;
  final String name;
  final double requiredQuantity;
  final double availableQuantity;
  final String unit;
  final double estimatedPrice;

  const HistoryShoppingItem({
    required this.ingredientId,
    required this.name,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.unit,
    required this.estimatedPrice,
  });

  double get missingQuantity =>
      (requiredQuantity - availableQuantity).clamp(0, double.infinity);

  factory HistoryShoppingItem.fromJson(Map<String, dynamic> json) {
    return HistoryShoppingItem(
      ingredientId: json['ingredient_id'] as int,
      name: json['name'] as String,
      requiredQuantity: (json['required_quantity'] as num).toDouble(),
      availableQuantity: (json['available_quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      estimatedPrice: (json['estimated_price'] as num).toDouble(),
    );
  }
}

/// تفاصيل خطة كاملة كما ترجعها GET /api/plans/{id}
class PlanDetail {
  final int id;
  final DateTime createdAt;
  final double budget;
  final double estimatedCost;
  final int numberOfMeals;
  final int daysPerMeal;
  final int servings;
  final String prepTime;
  final List<HistoryMeal> meals;
  final List<HistoryShoppingItem> shoppingList;

  const PlanDetail({
    required this.id,
    required this.createdAt,
    required this.budget,
    required this.estimatedCost,
    required this.numberOfMeals,
    required this.daysPerMeal,
    required this.servings,
    required this.prepTime,
    required this.meals,
    required this.shoppingList,
  });

  double get totalShoppingPrice =>
      shoppingList.fold(0, (sum, item) => sum + item.estimatedPrice);

  factory PlanDetail.fromJson(Map<String, dynamic> json) {
    return PlanDetail(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      budget: (json['budget'] as num).toDouble(),
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      numberOfMeals: json['number_of_meals'] as int,
      daysPerMeal: json['days_per_meal'] as int,
      servings: json['servings'] as int,
      prepTime: json['prep_time'] as String,
      meals: (json['meals'] as List)
          .map((e) => HistoryMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
      shoppingList: (json['shopping_list'] as List)
          .map((e) => HistoryShoppingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
