import 'package:equatable/equatable.dart';

class MealModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> ingredients;
  final List<String> missingIngredients;
  final int cookingTimeMinutes;
  final int servings;
  final double estimatedCost;
  final String difficulty;
  final List<String> tags;
  final double rating;
  final String imageEmoji;

  const MealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.ingredients,
    required this.missingIngredients,
    required this.cookingTimeMinutes,
    required this.servings,
    required this.estimatedCost,
    required this.difficulty,
    required this.tags,
    required this.rating,
    required this.imageEmoji,
  });

  @override
  List<Object?> get props => [id, name];
}

/// Cooking time bracket selected by the user on the weekly plan request screen.
enum CookingTimeLevel {
  short, // قليل
  // shortToMedium, // من قليل لمتوسط
  medium, // من قليل لمتوسط
  // mediumToLong, // من متوسط لطويل
  long, // طويل
}

extension CookingTimeLevelX on CookingTimeLevel {
  String get label {
    switch (this) {
      case CookingTimeLevel.short:
        return 'قليل';
      case CookingTimeLevel.medium:
        return 'لمتوسط';
      // case CookingTimeLevel.mediumToLong:
      //   return 'من متوسط لطويل';
      case CookingTimeLevel.long:
        return 'طويل';
    }
  }

  String get subtitle {
    switch (this) {
      case CookingTimeLevel.short:
        return 'أقل من ٢٠ دقيقة';
      case CookingTimeLevel.medium:
        return '٢٠ - ٤٠ دقيقة';
      // case CookingTimeLevel.mediumToLong:
      //   return '٤٠ - ٧٠ دقيقة';
      case CookingTimeLevel.long:
        return 'أكثر من ٧٠ دقيقة';
    }
  }

  int get maxMinutes {
    switch (this) {
      case CookingTimeLevel.short:
        return 20;
      case CookingTimeLevel.medium:
        return 40;
      // case CookingTimeLevel.mediumToLong:
      //   return 70;
      case CookingTimeLevel.long:
        return 999;
    }
  }
}

class MealRequest extends Equatable {
  final double budget;
  final List<String> availableIngredients;
  final CookingTimeLevel cookingTimeLevel;
  final bool
      assumeBasicsAvailable; // معجون البندورة، دبس الرمان، الملح، الزيوت...

  const MealRequest({
    required this.budget,
    required this.availableIngredients,
    required this.cookingTimeLevel,
    required this.assumeBasicsAvailable,
  });

  @override
  List<Object?> get props =>
      [budget, availableIngredients, cookingTimeLevel, assumeBasicsAvailable];
}

// Fake data repository
class MealRepository {
  static final List<MealModel> _allMeals = [
    MealModel(
      id: 'm1',
      name: "كبة مقلية",
      description:
          'كبة لحم مشوية على الطريقة الشامية مع التوابل الأصيلة والمكسرات',
      category: 'أطباق رئيسية',
      ingredients: [
        'لحم مفروم',
        'برغل',
        'بصل',
        'توابل شامية',
        'صنوبر',
        'زيت زيتون'
      ],
      missingIngredients: ['صنوبر', 'برغل'],
      cookingTimeMinutes: 45,
      servings: 4,
      estimatedCost: 350.0,
      difficulty: 'متوسط',
      tags: ['شامي', 'مشوي', 'لحوم'],
      rating: 4.8,
      imageEmoji: '🍖',
    ),
    MealModel(
      id: 'm2',
      name: "تسقية",
      description: 'طبق فتة الحمص المميز مع الخبز المحمص والزبادي والسمن',
      category: 'أطباق رئيسية',
      ingredients: [
        'حمص مسلوق',
        'خبز',
        'زبادي',
        'سمن',
        'ثوم',
        'ليمون',
        'طحينة'
      ],
      missingIngredients: ['طحينة', 'سمن'],
      cookingTimeMinutes: 30,
      servings: 4,
      estimatedCost: 180.0,
      difficulty: 'سهل',
      tags: ['نباتي', 'سريع', 'اقتصادي'],
      rating: 4.6,
      imageEmoji: '🫘',
    ),
    MealModel(
      id: 'm3',
      name: "كبسة",
      description: 'أرز بالورق وباللحم مع صلصة اللبن الأصيلة والمكسرات المحمصة',
      category: 'أطباق رئيسية',
      ingredients: ['أرز', 'لحم غنم', 'لبن جميد', 'بصل', 'هيل', 'مكسرات'],
      missingIngredients: ['لبن جميد', 'مكسرات'],
      cookingTimeMinutes: 90,
      servings: 6,
      estimatedCost: 650.0,
      difficulty: 'صعب',
      tags: ['مناسبات', 'لحوم', 'أرز'],
      rating: 4.9,
      imageEmoji: '🍚',
    ),
    MealModel(
      id: 'm4',
      name: 'شوربة العدس',
      description: 'شوربة العدس الكريمية الدافئة مع الكمون والليمون',
      category: 'شوربات',
      ingredients: [
        'عدس أحمر',
        'بصل',
        'ثوم',
        'كمون',
        'كركم',
        'ليمون',
        'زيت زيتون'
      ],
      missingIngredients: ['كركم'],
      cookingTimeMinutes: 25,
      servings: 4,
      estimatedCost: 80.0,
      difficulty: 'سهل',
      tags: ['نباتي', 'صحي', 'سريع', 'اقتصادي'],
      rating: 4.5,
      imageEmoji: '🍲',
    ),
    MealModel(
      id: 'm5',
      name: 'مجدرة',
      description: 'العدس مع الأرز والبصل المقرمش، طبق سوري كلاسيكي شهي',
      category: 'أطباق رئيسية',
      ingredients: ['عدس بني', 'أرز', 'بصل', 'زيت زيتون', 'كمون', 'ملح'],
      missingIngredients: [],
      cookingTimeMinutes: 40,
      servings: 4,
      estimatedCost: 120.0,
      difficulty: 'سهل',
      tags: ['نباتي', 'اقتصادي', 'صحي'],
      rating: 4.7,
      imageEmoji: '🫙',
    ),
    MealModel(
      id: 'm6',
      name: 'دجاج بالفرن مع الثوم',
      description:
          'دجاج كامل محشو بالثوم والأعشاب مشوي بالفرن على الطريقة الشامية',
      category: 'دواجن',
      ingredients: [
        'دجاج كامل',
        'ثوم',
        'ليمون',
        'زيت زيتون',
        'توابل',
        'بقدونس'
      ],
      missingIngredients: ['بقدونس'],
      cookingTimeMinutes: 60,
      servings: 4,
      estimatedCost: 280.0,
      difficulty: 'متوسط',
      tags: ['دواجن', 'فرن', 'عائلي'],
      rating: 4.8,
      imageEmoji: '🍗',
    ),
    MealModel(
      id: 'm7',
      name: 'تبولة',
      description: 'سلطة البقدونس والبرغل الطازجة مع الطماطم والليمون',
      category: 'سلطات',
      ingredients: [
        'بقدونس',
        'برغل ناعم',
        'طماطم',
        'بصل أخضر',
        'ليمون',
        'زيت زيتون',
        'نعنع'
      ],
      missingIngredients: ['نعنع طازج'],
      cookingTimeMinutes: 15,
      servings: 4,
      estimatedCost: 90.0,
      difficulty: 'سهل',
      tags: ['نباتي', 'صحي', 'سريع', 'خفيف'],
      rating: 4.6,
      imageEmoji: '🥗',
    ),
    MealModel(
      id: 'm8',
      name: 'مسخن فلسطيني',
      description: 'دجاج مشوي بالزيت والبصل فوق خبز التنور مع البهارات الشامية',
      category: 'دواجن',
      ingredients: ['دجاج', 'بصل', 'زيت زيتون', 'خبز تنور', 'بهارات', 'برسوم'],
      missingIngredients: ['خبز تنور', 'برسوم'],
      cookingTimeMinutes: 50,
      servings: 4,
      estimatedCost: 260.0,
      difficulty: 'متوسط',
      tags: ['دواجن', 'شامي', 'عائلي'],
      rating: 4.7,
      imageEmoji: '🫓',
    ),
  ];

  static List<MealModel> getRecommendations(MealRequest request) {
    return _allMeals.where((meal) {
      return meal.estimatedCost <= request.budget &&
          meal.cookingTimeMinutes <= request.cookingTimeLevel.maxMinutes;
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  static List<MealModel> getAllMealsHistory() => _allMeals.take(4).toList();
}
