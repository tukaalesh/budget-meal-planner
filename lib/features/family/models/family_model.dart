// import 'package:equatable/equatable.dart';

// class FamilyModel extends Equatable {
//   final int memberCount;
//   final List<String> favoriteDishes;
//   final List<String> dislikedDishes;
//   final List<String> dislikedIngredients;
//   final List<String> allergies;
//   final List<String>
//       availableBasicIngredients; // المكونات الأساسية المتوفرة دائماً

//   const FamilyModel({
//     required this.memberCount,
//     required this.favoriteDishes,
//     required this.dislikedDishes,
//     required this.dislikedIngredients,
//     required this.allergies,
//     this.availableBasicIngredients = const [],
//   });

//   /// يحوّل النموذج للـ JSON المطلوب من الباك اند
//   Map<String, dynamic> toApiJson() {
//     return {
//       'family_members': memberCount,
//       'favorite_meals': favoriteDishes,
//       'disliked_meals': dislikedDishes,
//       'disliked_ingredients': dislikedIngredients,
//       'allergic_ingredients': allergies,
//       'always_available_ingredients': availableBasicIngredients,
//     };
//   }

//   FamilyModel copyWith({
//     int? memberCount,
//     List<String>? favoriteDishes,
//     List<String>? dislikedDishes,
//     List<String>? dislikedIngredients,
//     List<String>? allergies,
//     List<String>? availableBasicIngredients,
//   }) {
//     return FamilyModel(
//       memberCount: memberCount ?? this.memberCount,
//       favoriteDishes: favoriteDishes ?? this.favoriteDishes,
//       dislikedDishes: dislikedDishes ?? this.dislikedDishes,
//       dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
//       allergies: allergies ?? this.allergies,
//       availableBasicIngredients:
//           availableBasicIngredients ?? this.availableBasicIngredients,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         memberCount,
//         favoriteDishes,
//         dislikedDishes,
//         dislikedIngredients,
//         allergies,
//         availableBasicIngredients,
//       ];
// }
import 'package:equatable/equatable.dart';

class FamilyModel extends Equatable {
  final int memberCount;
  final List<String> favoriteDishes;
  final List<String> dislikedDishes;
  final List<String> dislikedIngredients;
  final List<String> allergies;
  final List<String>
      availableBasicIngredients; 

  const FamilyModel({
    required this.memberCount,
    required this.favoriteDishes,
    required this.dislikedDishes,
    required this.dislikedIngredients,
    required this.allergies,
    this.availableBasicIngredients = const [],
  });

  /// يحوّل النموذج للـ JSON المطلوب من الباك اند (POST / PUT)
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
  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    List<String> asStringList(dynamic v) =>
        (v as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    return FamilyModel(
      memberCount: json['family_size'] ?? 1,
      favoriteDishes: asStringList(json['favorite_meals']),
      dislikedDishes: asStringList(json['disliked_meals']),
      dislikedIngredients: asStringList(json['disliked_ingredients']),
      allergies: asStringList(json['allergic_ingredients']),
      availableBasicIngredients:
          asStringList(json['always_available_ingredients']),
    );
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