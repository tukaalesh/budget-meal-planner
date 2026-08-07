import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/meal_model.dart';

/// يحسب تسمية اليوم/الأيام لوجبة حسب ترتيبها ومدة بقائها (days_per_meal).
/// مثال: daysPerMeal=1 → الوجبة الأولى "اليوم 1"، الثانية "اليوم 2"...
/// daysPerMeal=2 → الوجبة الأولى "اليوم 1 - اليوم 2"، الثانية "اليوم 3 - اليوم 4"...
String mealDayLabel(int index, int daysPerMeal) {
  final span = daysPerMeal < 1 ? 1 : daysPerMeal;
  final startDay = index * span + 1;
  if (span == 1) {
    return 'اليوم $startDay';
  }
  final endDay = startDay + span - 1;
  return 'اليوم $startDay - اليوم $endDay';
}

class MealCard extends StatelessWidget {
  final PlanMeal meal;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback? onTap;
  final String dayLabel;

  const MealCard({
    super.key,
    required this.meal,
    required this.isLiked,
    required this.onLikeToggle,
    required this.dayLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(meal.name, style: textTheme.headlineSmall),
                ),
                IconButton(
                  onPressed: onLikeToggle,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? AppColors.primary : AppColors.textHint,
                  ),
                  tooltip: 'أحببت هذه الوجبة',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.calendar_today, label: dayLabel),
                _InfoChip(icon: Icons.schedule, label: meal.prepTime),
                _InfoChip(icon: Icons.bar_chart, label: meal.difficulty),
                _InfoChip(icon: Icons.eco_outlined, label: meal.seasonality),
                _InfoChip(
                  icon: Icons.payments_outlined,
                  label: meal.estimatedCost.toStringAsFixed(0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('المكونات', style: textTheme.titleSmall),
            const SizedBox(height: 6),
            ...meal.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 5, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(ingredient.name, style: textTheme.bodyMedium),
                    ),
                    Text(
                      '${ingredient.quantity.toStringAsFixed(0)} ${ingredient.unit}',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
