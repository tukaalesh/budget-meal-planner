// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/family_bloc.dart';
import '../models/family_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class FamilyInfoScreen extends StatefulWidget {
  const FamilyInfoScreen({super.key});

  @override
  State<FamilyInfoScreen> createState() => _FamilyInfoScreenState();
}

class _FamilyInfoScreenState extends State<FamilyInfoScreen> {
  int _memberCount = 4;

  // Favorite dishes — preset Syrian/Arabic dishes + manual add
  final List<String> _presetFavoriteDishes = [
    'كبسة',
    'مندي',
    'ملوخية',
    'شاكرية'
  ];
  final Set<String> _selectedFavoriteDishes = {};
  final List<String> _customFavoriteDishes = [];

  // Allergies — preset + manual add
  final List<String> _presetAllergies = [
    'مكسرات',
    'لبن',
    'بيض',
    'زيت',
  ];
  final Set<String> _selectedAllergies = {};
  final List<String> _customAllergies = [];

  // Disliked ingredients — manual add only
  final List<String> _dislikedIngredients = [];

  // Disliked dishes — manual add only
  final List<String> _dislikedDishes = [];

  // Cooking frequency: 'يوم واحد' أو 'يومين'
  String _cookingFrequency = 'يومين';

  // Delivery days per week
  int _deliveryDays = 1;

  void _submit() {
    final allFavorites = [..._selectedFavoriteDishes, ..._customFavoriteDishes];
    final allAllergies = [..._selectedAllergies, ..._customAllergies];

    context.read<FamilyBloc>().add(FamilyInfoSubmitted(FamilyModel(
          memberCount: _memberCount,
          favoriteDishes: allFavorites,
          allergies: allAllergies,
          dislikedIngredients: _dislikedIngredients,
          dislikedDishes: _dislikedDishes,
          cookingFrequency: _cookingFrequency,
          deliveryDaysPerWeek: _deliveryDays,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('معلومات العائلة'),
          centerTitle: false,
          backgroundColor: AppColors.background,
        ),
        body: BlocConsumer<FamilyBloc, FamilyState>(
          listener: (context, state) {
            if (state is FamilyLoaded) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withOpacity(0.08),
                          AppColors.accentLight.withOpacity(0.06)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.accent.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.family_restroom_rounded,
                            color: AppColors.accentLight, size: 40),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('دعنا نتعرف على عائلتك',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              SizedBox(height: 4),
                              Text('سنقترح وجبات مناسبة لجميع أفراد العائلة',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28),

                  // ── عدد أفراد العائلة ──────────────────────────────
                  Text('عدد أفراد العائلة',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => setState(() {
                            if (_memberCount > 1) _memberCount--;
                          }),
                          icon: Icon(Icons.remove_circle_outline_rounded,
                              color: AppColors.accent, size: 32),
                        ),
                        Column(
                          children: [
                            Text(
                              '$_memberCount',
                              style: GoogleFonts.cairo(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                            Text('أفراد',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            if (_memberCount < 20) _memberCount++;
                          }),
                          icon: Icon(Icons.add_circle_outline_rounded,
                              color: AppColors.accent, size: 32),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28),

                  // ── الأكلات المفضلة (كانت "التفضيلات الغذائية") ──────
                  Text('الأكلات المفضلة',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 4),
                  Text('اختر ما تفضله عائلتك من الأكلات',
                      style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetFavoriteDishes.map((dish) {
                      final selected = _selectedFavoriteDishes.contains(dish);
                      return AppChip(
                        label: dish,
                        isSelected: selected,
                        selectedColor: AppColors.accentLight,
                        onTap: () => setState(() {
                          if (selected) {
                            _selectedFavoriteDishes.remove(dish);
                          } else {
                            _selectedFavoriteDishes.add(dish);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  TaggedInputField(
                    label: 'إضافة أكلة أخرى يدويًا',
                    hint: 'مثال: شوربة خضار',
                    items: _customFavoriteDishes,
                    chipColor: AppColors.accent,
                    onAdd: (val) =>
                        setState(() => _customFavoriteDishes.add(val)),
                    onRemove: (val) =>
                        setState(() => _customFavoriteDishes.remove(val)),
                  ),
                  SizedBox(height: 28),

                  // ── الحساسية الغذائية ─────────────────────────────
                  Text('الحساسية الغذائية',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 4),
                  Text('اختر إن وجد',
                      style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetAllergies.map((allergy) {
                      final selected = _selectedAllergies.contains(allergy);
                      return AppChip(
                        label: allergy,
                        isSelected: selected,
                        selectedColor: AppColors.accentLight,
                        onTap: () => setState(() {
                          if (selected) {
                            _selectedAllergies.remove(allergy);
                          } else {
                            _selectedAllergies.add(allergy);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  TaggedInputField(
                    label: 'إضافة حساسية أخرى يدويًا',
                    hint: 'مثال: حليب',
                    items: _customAllergies,
                    chipColor: AppColors.accent,
                    onAdd: (val) => setState(() => _customAllergies.add(val)),
                    onRemove: (val) =>
                        setState(() => _customAllergies.remove(val)),
                  ),
                  SizedBox(height: 28),

                  // ── المكونات يلي مابحبوها ─────────────────────────
                  Text('المكونات التي لا تفضلها العائلة',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 4),
                  Text('أضف أي مكون لا ترغب برؤيته في وجباتك',
                      style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 12),
                  TaggedInputField(
                    label: 'إضافة مكون',
                    hint: 'مثال: بيتنجان',
                    items: _dislikedIngredients,
                    chipColor: AppColors.accent,
                    onAdd: (val) =>
                        setState(() => _dislikedIngredients.add(val)),
                    onRemove: (val) =>
                        setState(() => _dislikedIngredients.remove(val)),
                  ),
                  SizedBox(height: 28),

                  // ── الطبخات يلي مابفضلها ──────────────────────────
                  Text('الأطباق التي لا تفضلها العائلة',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 4),
                  Text('أضف أي طبق تريد استثناءه من التوصيات',
                      style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 12),
                  TaggedInputField(
                    label: 'إضافة طبق',
                    hint: 'مثال: بامية',
                    items: _dislikedDishes,
                    chipColor: AppColors.accent,
                    onAdd: (val) => setState(() => _dislikedDishes.add(val)),
                    onRemove: (val) =>
                        setState(() => _dislikedDishes.remove(val)),
                  ),
                  SizedBox(height: 28),

                  // ── هل يفضل الطبخ على يومين أو يوم واحد ──────────
                  Text('هل تفضل الطبخ على يومين أم يوم واحد؟',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceOptionCard(
                          label: 'يوم واحد',
                          subtitle: 'طبخ كل وجبة بيومها',
                          icon: Icons.looks_one_outlined,
                          isSelected: _cookingFrequency == 'يوم واحد',
                          onTap: () =>
                              setState(() => _cookingFrequency = 'يوم واحد'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ChoiceOptionCard(
                          label: 'يومين',
                          subtitle: 'طبخ يكفي ليومين',
                          icon: Icons.calendar_view_week_outlined,
                          isSelected: _cookingFrequency == 'يومين',
                          onTap: () =>
                              setState(() => _cookingFrequency = 'يومين'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28),

                  // ── كم عدد الأيام يلي بيطلبو فيها ديليفري ────────
                  Text('كم يوماً في الأسبوع تطلبون فيه ديليفري؟',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => setState(() {
                            if (_deliveryDays > 0) _deliveryDays--;
                          }),
                          icon: Icon(Icons.remove_circle_outline_rounded,
                              color: AppColors.accent, size: 32),
                        ),
                        Column(
                          children: [
                            Text(
                              '$_deliveryDays',
                              style: GoogleFonts.cairo(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                            Text('أيام / أسبوع',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            if (_deliveryDays < 6) _deliveryDays++;
                          }),
                          icon: Icon(Icons.add_circle_outline_rounded,
                              color: AppColors.accent, size: 32),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: 'حفظ ومتابعة',
                      onPressed: _submit,
                      isLoading: state is FamilyLoading,
                      icon: Icons.arrow_back_rounded,
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
