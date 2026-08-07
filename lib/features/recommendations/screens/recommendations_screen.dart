import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../meal_request/models/meal_request_model.dart';
import '../bloc/recommendations_bloc.dart';
import '../models/meal_model.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';
import 'shopping_list_screen.dart';

class RecommendationsScreen extends StatelessWidget {
  final MealRequestModel originalRequest;
  final GeneratedPlanModel plan;

  const RecommendationsScreen({
    super.key,
    required this.originalRequest,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthCubit>().state;
        final token = authState is AuthSuccess ? authState.user.token : null;
        return RecommendationsBloc(
          requestModel: originalRequest,
          initialPlan: plan,
          authToken: token,
        );
      },
      child: const _RecommendationsView(),
    );
  }
}

class _RecommendationsView extends StatefulWidget {
  const _RecommendationsView();

  @override
  State<_RecommendationsView> createState() => _RecommendationsViewState();
}

class _RecommendationsViewState extends State<_RecommendationsView> {
  bool _isDialogOpen = false;

  void _closeDialogIfOpen() {
    if (_isDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogOpen = false;
    }
  }

  void _showLoadingDialog(String message) {
    _isDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LoadingDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الخطة المقترحة')),
      body: BlocConsumer<RecommendationsBloc, RecommendationsState>(
        listenWhen: (prev, curr) =>
            prev.regenerateStatus != curr.regenerateStatus ||
            prev.acceptStatus != curr.acceptStatus,
        listener: (context, state) {
          if (state.regenerateStatus == AsyncStatus.loading) {
            _showLoadingDialog('جاري إعادة توليد الخطة...');
            return;
          }
          if (state.acceptStatus == AsyncStatus.loading) {
            _showLoadingDialog('جاري تأكيد الخطة...');
            return;
          }

          _closeDialogIfOpen();

          if (state.regenerateStatus == AsyncStatus.failure ||
              state.acceptStatus == AsyncStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'حدث خطأ')),
            );
          }

          if (state.acceptStatus == AsyncStatus.success &&
              state.acceptResponse != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    ShoppingListScreen(response: state.acceptResponse!),
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<RecommendationsBloc>();
          final isBusy = state.regenerateStatus == AsyncStatus.loading ||
              state.acceptStatus == AsyncStatus.loading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PlanSummaryCard(requestModel: state.requestModel, plan: state.plan),
                const SizedBox(height: 20),
                Text('الوجبات المقترحة',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final meal in state.plan.meals)
                  MealCard(
                    meal: meal,
                    isLiked: state.isLiked(meal.mealId),
                    onLikeToggle: () =>
                        bloc.add(MealLikeToggled(meal.mealId)),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: MealDetailScreen(meal: meal),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed:
                      isBusy ? null : () => bloc.add(const PlanRegenerationRequested()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة طلب الخطة'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed:
                      isBusy ? null : () => bloc.add(const PlanAcceptRequested()),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('قبول الخطة'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== بطاقة الملخص العام ====================

class _PlanSummaryCard extends StatelessWidget {
  final MealRequestModel requestModel;
  final GeneratedPlanModel plan;

  const _PlanSummaryCard({required this.requestModel, required this.plan});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final durationLabel =
        requestModel.daysPerMeal == 2 ? 'يومين' : 'يوم واحد';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ملخص الخطة', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            _SummaryRow(label: 'الميزانية', value: requestModel.budget.toStringAsFixed(0)),
            _SummaryRow(label: 'عدد الأشخاص', value: '${requestModel.servings}'),
            _SummaryRow(label: 'وقت التحضير', value: requestModel.prepTime.label),
            _SummaryRow(label: 'مدة الوجبة الواحدة', value: durationLabel),
            const Divider(height: 24, color: AppColors.divider),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('التكلفة الإجمالية', style: textTheme.titleMedium),
                Text(
                  plan.totalCost.toStringAsFixed(0),
                  style: textTheme.titleLarge
                      ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

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

// ==================== دايلوج التحميل (مشترك للحالتين) ====================

class _LoadingDialog extends StatelessWidget {
  final String message;
  const _LoadingDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'قد يستغرق هذا حتى دقيقة، الرجاء الانتظار',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
