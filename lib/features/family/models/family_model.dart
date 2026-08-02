import 'package:equatable/equatable.dart';

class FamilyModel extends Equatable {
  final int memberCount;
  final List<String> favoriteDishes;
  final List<String> dislikedDishes;
  final List<String> dislikedIngredients;
  final List<String> allergies;
  final List<String>
      availableBasicIngredients; // المكونات الأساسية المتوفرة دائماً

  const FamilyModel({
    required this.memberCount,
    required this.favoriteDishes,
    required this.dislikedDishes,
    required this.dislikedIngredients,
    required this.allergies,
    this.availableBasicIngredients = const [],
  });

  /// يحوّل النموذج للـ JSON المطلوب من الباك اند
  Map<String, dynamic> toApiJson() {
    return {
      'family_members': memberCount,
      'favorite_meals': favoriteDishes,
      'disliked_meals': dislikedDishes,
      'disliked_ingredients': dislikedIngredients,
      'allergic_ingredients': allergies,
      'always_available_ingredients': availableBasicIngredients,
    };
  }

  FamilyModel copyWith({
    int? memberCount,
    List<String>? favoriteDishes,
    List<String>? dislikedDishes,
    List<String>? dislikedIngredients,
    List<String>? allergies,
    List<String>? availableBasicIngredients,
  }) {
    return FamilyModel(
      memberCount: memberCount ?? this.memberCount,
      favoriteDishes: favoriteDishes ?? this.favoriteDishes,
      dislikedDishes: dislikedDishes ?? this.dislikedDishes,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      allergies: allergies ?? this.allergies,
      availableBasicIngredients:
          availableBasicIngredients ?? this.availableBasicIngredients,
    );
  }

  @override
  List<Object?> get props => [
        memberCount,
        favoriteDishes,
        dislikedDishes,
        dislikedIngredients,
        allergies,
        availableBasicIngredients,
      ];
}
