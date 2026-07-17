// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/meal_request_bloc.dart';
import '../../recommendations/models/meal_model.dart';
// ignore: unused_import
import '../../recommendations/screens/recommendations_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class MealRequestScreen extends StatefulWidget {
  const MealRequestScreen({super.key});

  @override
  State<MealRequestScreen> createState() => _MealRequestScreenState();
}

class _MealRequestScreenState extends State<MealRequestScreen> {
  final _budgetCtrl = TextEditingController();
  final _ingredientNameCtrl = TextEditingController();
  final _ingredientQtyCtrl = TextEditingController();
  final List<String> _availableIngredients = [];

  CookingTimeLevel _cookingTimeLevel = CookingTimeLevel.long;

  // المكونات الأساسية التي يمكن للمستخدم تحديد أنها متوفرة لديه
  static const List<String> _basicIngredientsOptions = [
    'زيوت',
    'دبس رمان',
    'معجون البندورة',
    'معجون الفليفلة',
    "بهارات"
  ];

  final Set<String> _selectedBasicIngredients = {};

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _ingredientNameCtrl.dispose();
    _ingredientQtyCtrl.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final name = _ingredientNameCtrl.text.trim();
    final rawQty = _ingredientQtyCtrl.text.trim();

    if (name.isEmpty || rawQty.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال اسم المكوّن وكميته معاً',
              style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // إذا كانت الكمية رقماً فقط (بدون وحدة)، نضيف الوحدة تلقائياً:
    // "حبة" للبيض، و"g" لباقي المكونات.
    String qty = rawQty;
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(rawQty)) {
      final unit = name.contains('بيض') ? 'حبة' : 'g';
      qty = '$rawQty $unit';
    }

    final entry = '$name - $qty';

    setState(() {
      _availableIngredients.add(entry);
      _ingredientNameCtrl.clear();
      _ingredientQtyCtrl.clear();
    });
  }

  void _submit() {
    final budget = double.tryParse(_budgetCtrl.text) ?? 0;
    if (budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أدخل الميزانية المتاحة', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // نضيف أي مكونات أساسية تم تحديدها إلى قائمة المكونات المتوفرة
    final combinedIngredients = [
      ..._availableIngredients,
      ..._selectedBasicIngredients
          .where((ing) => !_availableIngredients.contains(ing)),
    ];

    context.read<MealRequestBloc>().add(MealRequestSubmitted(MealRequest(
          budget: budget,
          availableIngredients: combinedIngredients,
          cookingTimeLevel: _cookingTimeLevel,
          assumeBasicsAvailable: false,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<MealRequestBloc, MealRequestState>(
        listener: (context, state) {
          if (state is MealRequestSuccess) {
            // Navigator.of(context).push(MaterialPageRoute(
            //   builder: (_) => BlocProvider.value(
            //     value: context.read<MealRequestBloc>(),
            //     child: RecommendationsScreen(),
            //   ),
            // ));
          } else if (state is MealRequestFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.cairo()),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  backgroundColor: AppColors.background,
                  centerTitle: false,
                  title: Text('خطة الوجبات الأسبوعية'),
                ),
                backgroundColor: AppColors.background,
                body: CustomScrollView(
                  slivers: [
                    // SliverAppBar(
                    //   pinned: true,
                    //   expandedHeight: 90,
                    //   backgroundColor: AppColors.surface,
                    //   flexibleSpace: FlexibleSpaceBar(
                    //     titlePadding: EdgeInsets.only(right: 16, bottom: 16),
                    //     title: Text('خطة الوجبات الأسبوعية',
                    //         style: GoogleFonts.cairo(
                    //           fontSize: 17,
                    //           fontWeight: FontWeight.w700,
                    //           color: AppColors.textPrimary,
                    //         )),
                    //     background: Container(
                    //       decoration: BoxDecoration(
                    //         gradient: LinearGradient(
                    //           colors: [
                    //             AppColors.primary.withOpacity(0.08),
                    //             AppColors.background
                    //           ],
                    //           begin: Alignment.topCenter,
                    //           end: Alignment.bottomCenter,
                    //         ),
                    //       ),
                    //       child: Row(
                    //         children: [
                    //           // Icon(Icons.auto_awesome_rounded,
                    //           //     color: AppColors.secondary, size: 28),
                    //           // SizedBox(width: 8),
                    //           // // Text(
                    //           // //   'دعنا نخطط لوجباتك الأسبوعية',
                    //           // //   style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 13),
                    //           // // ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SliverPadding(
                      padding: EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Budget
                          _SectionCard(
                            icon: Icons.attach_money_rounded,
                            title: 'الميزانية المتاحة',
                            iconColor: AppColors.success,
                            child: AppTextField(
                              label: 'الميزانية (بالليرة السورية)',
                              hint: 'مثال: 500',
                              controller: _budgetCtrl,
                              keyboardType: TextInputType.number,
                              // prefixIcon: Icon(Icons.money_rounded,
                              //     color: AppColors.textHint),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Available ingredients - name + quantity input
                          _SectionCard(
                            icon: Icons.kitchen_rounded,
                            title: 'المقادير المتوفرة',
                            iconColor: AppColors.accent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "أضف مقادير لديك حالياً مع كميتها بالغرام حصراً",
                                  style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: AppColors.textSecondary),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: AppTextField(
                                        label: 'المكوّن',
                                        hint: 'مثال: دجاج',
                                        controller: _ingredientNameCtrl,
                                        // prefixIcon: Icon(
                                        //     Icons.food_bank_outlined,
                                        //     color: AppColors.textHint),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: AppTextField(
                                        label: 'الكمية',
                                        hint: 'مثال: 200 غرام',
                                        controller: _ingredientQtyCtrl,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _addIngredient,
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.add_rounded,
                                            color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_availableIngredients.isNotEmpty) ...[
                                  SizedBox(height: 12),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: _availableIngredients.map((ing) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.accent.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: AppColors.accent
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              ing,
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                color: AppColors.accent,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () => setState(() =>
                                                  _availableIngredients
                                                      .remove(ing)),
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 14,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                if (_availableIngredients.isEmpty) ...[
                                  SizedBox(height: 10),
                                  Text(
                                    'اقتراحات شائعة:',
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                  SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: ['رز', 'بصل', 'بندورة', 'برغل']
                                        .map((ing) => GestureDetector(
                                              onTap: () {
                                                setState(() =>
                                                    _ingredientNameCtrl.text =
                                                        ing);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: AppColors.accent
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: AppColors.accent
                                                          .withOpacity(0.3)),
                                                ),
                                                child: Text(
                                                  '+ $ing',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 12,
                                                    color: AppColors.accent,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 16),

                          // Cooking time - level choice (replaces slider)
                          _SectionCard(
                            icon: Icons.timer_outlined,
                            title: 'وقت الطهي المتاح',
                            iconColor: AppColors.secondary,
                            child: Column(
                              children: CookingTimeLevel.values.map((level) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: ChoiceOptionCard(
                                    label: level.label,
                                    subtitle: level.subtitle,
                                    icon: Icons.timer_outlined,
                                    isSelected: _cookingTimeLevel == level,
                                    onTap: () => setState(
                                        () => _cookingTimeLevel = level),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Basic ingredients checklist
                          _SectionCard(
                            icon: Icons.help_outline_rounded,
                            title: 'سؤال مهم',
                            iconColor: AppColors.primaryLight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حدد أي من المكونات الأساسية التالية متوفرة لديك حالياً بكميات كافية حتى لا يتم احتساب تكلفتها من ميزانيتك:',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.5,
                                    color: AppColors.textPrimary,
                                    height: 1.6,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 14),
                                ..._basicIngredientsOptions
                                    .map((ing) => Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: ChoiceOptionCard(
                                            label: ing,
                                            isSelected:
                                                _selectedBasicIngredients
                                                    .contains(ing),
                                            onTap: () => setState(() {
                                              if (_selectedBasicIngredients
                                                  .contains(ing)) {
                                                _selectedBasicIngredients
                                                    .remove(ing);
                                              } else {
                                                _selectedBasicIngredients
                                                    .add(ing);
                                              }
                                            }),
                                          ),
                                        ))
                                    .toList(),
                              ],
                            ),
                          ),
                          SizedBox(height: 28),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: "توليد اقتراحات الوجبات",
                              onPressed: _submit,
                              isLoading: state is MealRequestLoading,
                            ),
                          ),
                          SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              if (state is MealRequestLoading)
                LoadingOverlay(
                    message: 'جاري تحليل متطلباتك واقتراح الوجبات المناسبة...'),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
