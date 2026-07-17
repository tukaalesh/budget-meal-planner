import 'package:equatable/equatable.dart';

class FamilyModel extends Equatable {
  final int memberCount;
  final List<String> favoriteDishes;
  final List<String> allergies;
  final List<String> dislikedIngredients;
  final List<String> dislikedDishes;
  final String cookingFrequency; // 'يوم واحد' or 'يومين'
  final int deliveryDaysPerWeek;

  const FamilyModel({
    required this.memberCount,
    required this.favoriteDishes,
    required this.allergies,
    required this.dislikedIngredients,
    required this.dislikedDishes,
    required this.cookingFrequency,
    required this.deliveryDaysPerWeek,
  });

  FamilyModel copyWith({
    int? memberCount,
    List<String>? favoriteDishes,
    List<String>? allergies,
    List<String>? dislikedIngredients,
    List<String>? dislikedDishes,
    String? cookingFrequency,
    int? deliveryDaysPerWeek,
  }) {
    return FamilyModel(
      memberCount: memberCount ?? this.memberCount,
      favoriteDishes: favoriteDishes ?? this.favoriteDishes,
      allergies: allergies ?? this.allergies,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      dislikedDishes: dislikedDishes ?? this.dislikedDishes,
      cookingFrequency: cookingFrequency ?? this.cookingFrequency,
      deliveryDaysPerWeek: deliveryDaysPerWeek ?? this.deliveryDaysPerWeek,
    );
  }

  @override
  List<Object?> get props => [
        memberCount,
        favoriteDishes,
        allergies,
        dislikedIngredients,
        dislikedDishes,
        cookingFrequency,
        deliveryDaysPerWeek,
      ];
}
