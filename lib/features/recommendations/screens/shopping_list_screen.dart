import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/shopping_list_model.dart';

class ShoppingListScreen extends StatelessWidget {
  final AcceptPlanResponseModel response;

  const ShoppingListScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة التسوق')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    response.message,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: response.shoppingList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = response.shoppingList[index];
                return _ShoppingItemTile(item: item);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('التكلفة التقديرية الإجمالية', style: textTheme.titleMedium),
                Text(
                  response.totalEstimatedPrice.toStringAsFixed(0),
                  style: textTheme.titleLarge
                      ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingListItem item;
  const _ShoppingItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_basket_outlined,
                  color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.ingredient, style: textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    'الكمية المطلوب شراؤها: ${item.missingQuantity.toStringAsFixed(0)} ${item.unit}',
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              item.estimatedPrice.toStringAsFixed(0),
              style: textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
