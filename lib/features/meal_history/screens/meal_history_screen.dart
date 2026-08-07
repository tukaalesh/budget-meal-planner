import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/meal_history_bloc.dart';
import '../models/plan_history_model.dart';
import 'plan_history_detail_screen.dart';

const _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String formatPlanDate(DateTime date) {
  return '${date.day} ${_kMonthNames[date.month - 1]} ${date.year}';
}

/// ملاحظة: هذه الشاشة لا تُنشئ MealHistoryBloc الخاص بها، بل تتوقع أنه
/// مزوّد من الأعلى (نفس نمط AuthCubit وFamilyBloc في التطبيق) - لأن
/// home_screen.dart يقرأ نفس الـ Bloc في الداشبورد أيضًا، ويجب أن تكون
/// نسخة واحدة فقط مشتركة بينهما.
class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // إذا كانت القائمة لم تُحمّل بعد فقط، لتجنّب إعادة الطلب في كل مرة
    // يُفتح فيها التبويب (بما أن home_screen يطلبها أصلًا عند بدء التطبيق).
    final bloc = context.read<MealHistoryBloc>();
    if (bloc.state.listStatus == AsyncStatus.idle) {
      bloc.add(const HistoryRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _MealHistoryView();
  }
}

class _MealHistoryView extends StatelessWidget {
  const _MealHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الخطط السابقة')),
      body: BlocBuilder<MealHistoryBloc, MealHistoryState>(
        builder: (context, state) {
          final bloc = context.read<MealHistoryBloc>();

          if (state.listStatus == AsyncStatus.loading ||
              state.listStatus == AsyncStatus.idle) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.listStatus == AsyncStatus.failure) {
            return _ErrorView(
              message: state.listErrorMessage ?? 'حدث خطأ',
              onRetry: () => bloc.add(const HistoryRequested()),
            );
          }

          if (state.plans.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh: () async => bloc.add(const HistoryRequested()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.plans.length,
              itemBuilder: (context, index) {
                final plan = state.plans[index];
                return _PlanSummaryTile(
                  plan: plan,
                  onTap: () {
                    bloc.add(PlanDetailRequested(plan.id));
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: PlanHistoryDetailScreen(planId: plan.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PlanSummaryTile extends StatelessWidget {
  final PlanSummary plan;
  final VoidCallback onTap;

  const _PlanSummaryTile({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = formatPlanDate(plan.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateLabel, style: textTheme.titleMedium),
                  Icon(Icons.chevron_left, color: AppColors.textHint),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniChip(
                    icon: Icons.restaurant_menu,
                    label: '${plan.numberOfMeals} وجبات',
                  ),
                  _MiniChip(
                    icon: Icons.groups_outlined,
                    label: '${plan.servings} أشخاص',
                  ),
                  _MiniChip(icon: Icons.schedule, label: plan.prepTime),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التكلفة',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                  Text(
                    '${plan.estimatedCost.toStringAsFixed(0)} / ${plan.budget.toStringAsFixed(0)}',
                    style: textTheme.titleSmall
                        ?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'لا يوجد لديك خطط سابقة بعد',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
