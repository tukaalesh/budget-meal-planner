import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/recommendations_bloc.dart';
import '../models/meal_model.dart';

/// شاشة تفاصيل وجبة واحدة. تقرأ حالة "الإعجاب" مباشرة من
/// RecommendationsBloc (عبر BlocProvider.value عند التنقل) حتى تبقى
/// متزامنة مع باقي الشاشة دون الحاجة لتمرير قيمة ثابتة.
class MealDetailScreen extends StatelessWidget {
  final PlanMeal meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<RecommendationsBloc, RecommendationsState>(
      buildWhen: (prev, curr) =>
          prev.isLiked(meal.mealId) != curr.isLiked(meal.mealId),
      builder: (context, state) {
        final isLiked = state.isLiked(meal.mealId);
        return Scaffold(
          appBar: AppBar(
            title: Text(meal.name),
            actions: [
              IconButton(
                onPressed: () => context
                    .read<RecommendationsBloc>()
                    .add(MealLikeToggled(meal.mealId)),
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.primary : AppColors.textHint,
                ),
                tooltip: 'أحببت هذه الوجبة',
              ),
            ],
          ),
          body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DetailChip(
                icon: Icons.schedule,
                label: 'وقت التحضير',
                value: meal.prepTime,
              ),
              _DetailChip(
                icon: Icons.bar_chart,
                label: 'الصعوبة',
                value: meal.difficulty,
              ),
              _DetailChip(
                icon: Icons.eco_outlined,
                label: 'الموسم',
                value: meal.seasonality,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التكلفة التقديرية', style: textTheme.titleMedium),
                  Text(
                    meal.estimatedCost.toStringAsFixed(0),
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('المكونات', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          ...meal.ingredients.map(
            (ingredient) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.restaurant_outlined,
                      color: AppColors.accent, size: 18),
                ),
                title: Text(ingredient.name),
                trailing: Text(
                  '${ingredient.quantity.toStringAsFixed(0)} ${ingredient.unit}',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              Text(value, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ],
      ),
    );
  }
}
