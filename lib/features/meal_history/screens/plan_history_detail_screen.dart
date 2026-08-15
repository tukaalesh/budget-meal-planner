import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/meal_history_bloc.dart';
import '../models/plan_history_model.dart';
import 'meal_history_screen.dart' show formatPlanDate;

class PlanHistoryDetailScreen extends StatelessWidget {
  final int planId;
  const PlanHistoryDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('تفاصيل الخطة')),
      body: BlocBuilder<MealHistoryBloc, MealHistoryState>(
        builder: (context, state) {
          if (state.detailStatus == AsyncStatus.loading ||
              state.detailStatus == AsyncStatus.idle) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.detailStatus == AsyncStatus.failure ||
              state.selectedPlan == null) {
            return _ErrorView(
              message: state.detailErrorMessage ?? 'حدث خطأ',
              onRetry: () => context
                  .read<MealHistoryBloc>()
                  .add(PlanDetailRequested(planId)),
            );
          }

          final plan = state.selectedPlan!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(plan: plan),
              const SizedBox(height: 20),
              Text('الوجبات', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              for (final meal in plan.meals) _HistoryMealCard(meal: meal),
              const SizedBox(height: 20),
              Text('قائمة التسوق',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              for (final item in plan.shoppingList)
                _ShoppingItemTile(item: item),
              const SizedBox(height: 12),
              Card(
                color: AppColors.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('إجمالي قائمة التسوق',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        plan.totalShoppingPrice.toStringAsFixed(0),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final PlanDetail plan;
  const _SummaryCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = formatPlanDate(plan.createdAt);
    final durationLabel = plan.daysPerMeal == 2 ? 'يومين' : 'يوم واحد';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            _Row(label: 'الميزانية', value: plan.budget.toStringAsFixed(0)),
            _Row(label: 'عدد الأشخاص', value: '${plan.servings}'),
            _Row(label: 'عدد الوجبات', value: '${plan.numberOfMeals}'),
            _Row(label: 'وقت التحضير', value: plan.prepTime),
            _Row(label: 'مدة الوجبة الواحدة', value: durationLabel),
            const Divider(height: 24, color: AppColors.divider),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('التكلفة الفعلية', style: textTheme.titleMedium),
                Text(
                  plan.estimatedCost.toStringAsFixed(0),
                  style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HistoryMealCard extends StatelessWidget {
  final HistoryMeal meal;
  const _HistoryMealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(meal.name, style: textTheme.titleLarge),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('اليوم ${meal.day}',
                      style: textTheme.labelMedium
                          ?.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'التكلفة: ${meal.estimatedCost.toStringAsFixed(0)}',
              style:
                  textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ...meal.ingredients.map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.circle,
                        size: 5, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Expanded(child: Text(i.name, style: textTheme.bodyMedium)),
                    Text(
                      '${i.quantity.toStringAsFixed(0)} ${i.unit}',
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
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final HistoryShoppingItem item;
  const _ShoppingItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shopping_basket_outlined,
              color: AppColors.secondary, size: 18),
        ),
        title: Text(item.name),
        subtitle:
            Text('${item.missingQuantity.toStringAsFixed(0)} ${item.unit}'),
        trailing: Text(item.estimatedPrice.toStringAsFixed(0),
            style: textTheme.titleSmall),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
