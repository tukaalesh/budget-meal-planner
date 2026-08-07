class ShoppingListItem {
  final String ingredient;
  final double requiredQuantity;
  final double availableQuantity;
  final String unit;
  final double estimatedPrice;

  const ShoppingListItem({
    required this.ingredient,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.unit,
    required this.estimatedPrice,
  });

  /// الكمية المتبقية التي يجب شراؤها فعليًا
  double get missingQuantity =>
      (requiredQuantity - availableQuantity).clamp(0, double.infinity);

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      ingredient: json['ingredient'] as String,
      requiredQuantity: (json['required_quantity'] as num).toDouble(),
      availableQuantity: (json['available_quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      estimatedPrice: (json['estimated_price'] as num).toDouble(),
    );
  }
}

class AcceptPlanResponseModel {
  final String message;
  final int planId;
  final List<ShoppingListItem> shoppingList;

  const AcceptPlanResponseModel({
    required this.message,
    required this.planId,
    required this.shoppingList,
  });

  double get totalEstimatedPrice =>
      shoppingList.fold(0, (sum, item) => sum + item.estimatedPrice);

  factory AcceptPlanResponseModel.fromJson(Map<String, dynamic> json) {
    return AcceptPlanResponseModel(
      message: json['message'] as String,
      planId: json['plan_id'] as int,
      shoppingList: (json['shopping_list'] as List)
          .map((e) => ShoppingListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
