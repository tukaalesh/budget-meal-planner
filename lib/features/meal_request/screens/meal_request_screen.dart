import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/search_api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../recommendations/screens/recommendations_screen.dart';
import '../bloc/meal_request_bloc.dart';
import '../models/meal_request_model.dart';

class MealRequestScreen extends StatelessWidget {
  const MealRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthCubit>().state;
        final token = authState is AuthSuccess ? authState.user.token : null;
        return MealRequestBloc(authToken: token);
      },
      child: const _MealRequestView(),
    );
  }
}

class _MealRequestView extends StatefulWidget {
  const _MealRequestView();

  @override
  State<_MealRequestView> createState() => _MealRequestViewState();
}

class _MealRequestViewState extends State<_MealRequestView> {
  final _budgetController = TextEditingController();
  bool _isDialogOpen = false;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _closeDialogIfOpen() {
    if (_isDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب خطة وجبات')),
      body: BlocConsumer<MealRequestBloc, MealRequestState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == SubmissionStatus.loading) {
            _isDialogOpen = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const _GeneratingPlanDialog(),
            );
            return;
          }

          _closeDialogIfOpen();

          if (state.status == SubmissionStatus.success &&
              state.generatedPlan != null) {
            final requestModel = MealRequestModel(
              budget: state.budget!,
              servings: state.servings,
              numberOfMeals: state.numberOfMeals,
              daysPerMeal: state.daysPerMeal,
              prepTime: state.prepTime,
              availableIngredients: state.availableIngredients,
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecommendationsScreen(
                  originalRequest: requestModel,
                  plan: state.generatedPlan!,
                ),
              ),
            );
          } else if (state.status == SubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'حدث خطأ')),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<MealRequestBloc>();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BudgetField(
                  controller: _budgetController,
                  state: state,
                  onChanged: (v) => bloc.add(BudgetChanged(v)),
                ),
                const SizedBox(height: 24),
                _CounterField(
                  label: 'عدد الأشخاص',
                  value: state.servings,
                  min: MealRequestBloc.minServings,
                  max: MealRequestBloc.maxServings,
                  onIncrement: () => bloc.add(const ServingsIncremented()),
                  onDecrement: () => bloc.add(const ServingsDecremented()),
                ),
                const SizedBox(height: 24),
                _CounterField(
                  label: 'عدد الوجبات',
                  value: state.numberOfMeals,
                  min: MealRequestBloc.minMeals,
                  max: MealRequestBloc.maxMeals,
                  onIncrement: () => bloc.add(const MealsCountIncremented()),
                  onDecrement: () => bloc.add(const MealsCountDecremented()),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  title: const Text('هل تفضل أن تكون الأكلة الواحدة على يومين؟'),
                  value: state.spreadOverTwoDays,
                  onChanged: (v) =>
                      bloc.add(SpreadOverTwoDaysToggled(v ?? false)),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<PrepTime>(
                  value: state.prepTime,
                  decoration: const InputDecoration(labelText: 'وقت التحضير'),
                  items: PrepTime.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.label),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) bloc.add(PrepTimeSelected(v));
                  },
                ),
                const SizedBox(height: 24),
                _IngredientsSection(state: state, bloc: bloc),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: state.status == SubmissionStatus.loading
                      ? null
                      : () => bloc.add(const PlanGenerationSubmitted()),
                  child: const Text('توليد الخطة'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== دايلوج الانتظار ====================

class _GeneratingPlanDialog extends StatelessWidget {
  const _GeneratingPlanDialog();

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
                'جاري توليد خطتك الغذائية...',
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

// ==================== حقل الميزانية ====================

class _BudgetField extends StatelessWidget {
  final TextEditingController controller;
  final MealRequestState state;
  final ValueChanged<String> onChanged;

  const _BudgetField({
    required this.controller,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showError = state.budgetTouched && !state.isBudgetValid;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'الميزانية',
        errorText: showError ? 'الرجاء إدخال الميزانية' : null,
      ),
    );
  }
}

// ==================== عداد رقمي ====================

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CounterField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        _RoundIconButton(
          icon: Icons.remove,
          onPressed: value > min ? onDecrement : null,
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _RoundIconButton(
          icon: Icons.add,
          onPressed: value < max ? onIncrement : null,
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.divider.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.textHint,
        ),
      ),
    );
  }
}

// ==================== قسم المكونات المتاحة ====================

class _IngredientsSection extends StatelessWidget {
  final MealRequestState state;
  final MealRequestBloc bloc;

  const _IngredientsSection({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('المكونات المتوفرة لديك (اختياري)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (int i = 0; i < state.availableIngredients.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _IngredientRow(
              ingredient: state.availableIngredients[i],
              onQuantityChanged: (q) =>
                  bloc.add(IngredientQuantityChanged(i, q)),
              onRemove: () => bloc.add(IngredientRemoved(i)),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => _showAddIngredientSheet(context, bloc),
          icon: const Icon(Icons.add),
          label: const Text('إضافة مكوّن'),
        ),
      ],
    );
  }

  Future<void> _showAddIngredientSheet(
      BuildContext context, MealRequestBloc bloc) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddIngredientSheet(bloc: bloc),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final AvailableIngredient ingredient;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRemove;

  const _IngredientRow({
    required this.ingredient,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(ingredient.name,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            SizedBox(
              width: 90,
              child: TextFormField(
                initialValue: ingredient.quantity ==
                        ingredient.quantity.roundToDouble()
                    ? ingredient.quantity.toInt().toString()
                    : ingredient.quantity.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  isDense: true,
                  suffixText: ingredient.unit,
                ),
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) onQuantityChanged(parsed);
                },
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

/// شيت لإضافة مكوّن جديد: بحث عن اسم المكوّن + إدخال الكمية.
/// البحث يستدعي SearchApiService مباشرة (مو عبر الـ Bloc) لأن نتائج
/// البحث محلية ومؤقتة داخل هذا الشيت فقط.
class _AddIngredientSheet extends StatefulWidget {
  final MealRequestBloc bloc;
  const _AddIngredientSheet({required this.bloc});

  @override
  State<_AddIngredientSheet> createState() => _AddIngredientSheetState();
}

class _AddIngredientSheetState extends State<_AddIngredientSheet> {
  IngredientOption? _selected;
  final _quantityController = TextEditingController();

  Future<Iterable<IngredientOption>> _search(String query) async {
    if (query.trim().length < 2) return const [];
    final result = await SearchApiService.searchIngredients(query);
    if (!result.isSuccess || result.data == null) return const [];
    return result.data!.map((name) => IngredientOption(name: name));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('إضافة مكوّن', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Autocomplete<IngredientOption>(
            displayStringForOption: (o) => o.name,
            optionsBuilder: (textEditingValue) => _search(textEditingValue.text),
            onSelected: (option) => setState(() => _selected = option),
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'ابحث عن اسم المكوّن',
                  prefixIcon: Icon(Icons.search),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            enabled: _selected != null,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'الكمية',
              suffixText: _selected?.unit,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selected == null
                ? null
                : () {
                    final qty = double.tryParse(_quantityController.text);
                    if (qty == null || qty <= 0) return;
                    widget.bloc.add(IngredientAdded(
                      AvailableIngredient(
                        name: _selected!.name,
                        unit: _selected!.unit,
                        quantity: qty,
                      ),
                    ));
                    Navigator.of(context).pop();
                  },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}
