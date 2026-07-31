// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/family_bloc.dart';
import '../models/family_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

// ── Static data pools ────────────────────────────────────────────────────────

const _kDishes = [
  'كبسة',
  'مندي',
  'ملوخية',
  'شاكرية',
  'كبة',
  'مجدرة',
  'فتة حمص',
  'منسف',
  'ورق عنب',
  'مسخن',
  'دجاج بالفرن',
  'مقلوبة',
  'فتوش',
  'تبولة',
  'حمص بالطحينة',
  'فلافل',
  'شوربة عدس',
  'يخنة بامية',
  'يخنة بازلاء',
  'برياني',
  'سلق',
  'معكرونة بالصلصة',
  'لازانيا',
  'كبة مشوية',
  'دجاج مشوي',
  'سمك مشوي',
  'موساكا',
  'خضار مشوية',
];

const _kIngredients = [
  'بصل',
  'ثوم',
  'طماطم',
  'فليفلة',
  'باذنجان',
  'كوسا',
  'جزر',
  'بطاطا',
  'بقدونس',
  'نعنع',
  'كزبرة',
  'كركم',
  'كمون',
  'قرفة',
  'هيل',
  'فلفل أسود',
  'دبس رمان',
  'طحينة',
  'ليمون',
  'خل',
  'مكسرات',
  'صنوبر',
  'حمص',
  'عدس',
  'أرز',
  'برغل',
  'قمح',
  'دجاج',
  'لحم غنم',
  'لحم بقر',
  'سمك',
  'جبنة',
  'زبادي',
  'لبن',
  'بيض',
  'سمنة',
  'زيت زيتون',
  'زيت نباتي',
  'خبز',
  'بهارات',
];

const _kAllergies = [
  'مكسرات',
  'لبن وألبان',
  'بيض',
  'قمح وجلوتين',
  'أسماك',
  'صدفيات',
  'سمسم',
  'فول سوداني',
  'فراولة',
  'مانجو',
  'ثوم',
  'بصل',
  'فليفلة حارة',
];

// ── Main screen ───────────────────────────────────────────────────────────────

class FamilyInfoScreen extends StatefulWidget {
  const FamilyInfoScreen({super.key});

  @override
  State<FamilyInfoScreen> createState() => _FamilyInfoScreenState();
}

class _FamilyInfoScreenState extends State<FamilyInfoScreen> {
  int _memberCount = 4;
  String _cookingFrequency = 'يومين';
  int _deliveryDays = 1;

  final Set<String> _favoriteDishes = {};
  final Set<String> _dislikedDishes = {};
  final Set<String> _dislikedIngredients = {};
  final Set<String> _allergies = {};

  void _submit() {
    context.read<FamilyBloc>().add(FamilyInfoSubmitted(FamilyModel(
          memberCount: _memberCount,
          favoriteDishes: _favoriteDishes.toList(),
          allergies: _allergies.toList(),
          dislikedIngredients: _dislikedIngredients.toList(),
          dislikedDishes: _dislikedDishes.toList(),
          cookingFrequency: _cookingFrequency,
          deliveryDaysPerWeek: _deliveryDays,
        )));
  }

  // Opens the searchable bottom sheet and waits for updated set
  Future<void> _openSearch({
    required String title,
    required String hint,
    required List<String> pool,
    required Set<String> selected,
    required ValueChanged<Set<String>> onChanged,
  }) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableSelectionSheet(
        title: title,
        hint: hint,
        pool: pool,
        initialSelected: Set.from(selected),
      ),
    );
    if (result != null) {
      setState(() => onChanged(result));
    }
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
          elevation: 0,
        ),
        body: BlocConsumer<FamilyBloc, FamilyState>(
          listener: (context, state) {
            if (state is FamilyLoaded) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro banner
                  // _InfoBanner(),

                  // ── عدد الأفراد ──────────────────────────────────
                  _SectionLabel('عدد أفراد العائلة'),
                  SizedBox(height: 12),
                  _CounterCard(
                    value: _memberCount,
                    unit: 'أفراد',
                    onDecrement: () => setState(() {
                      if (_memberCount > 1) _memberCount--;
                    }),
                    onIncrement: () => setState(() {
                      if (_memberCount < 20) _memberCount++;
                    }),
                  ),
                  SizedBox(height: 18),
                  Divider(
                    color: Colors.grey.withOpacity(0.3), // لون شبه شفاف
                    thickness: 1,
                    height: 13,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SizedBox(height: 18),
                  // ── الأكلات المفضلة ───────────────────────────────
                  _SectionLabel('الأكلات المفضلة'),
                  SizedBox(height: 4),
                  _SectionSubLabel('اختر الأكلات اللي تحبها عائلتك'),
                  SizedBox(height: 10),
                  _SearchTrigger(
                    hint: 'ابحث عن أكلة...',
                    count: _favoriteDishes.length,
                    onTap: () => _openSearch(
                      title: 'الأكلات المفضلة',
                      hint: 'ابحث: كبسة، ملوخية...',
                      pool: _kDishes,
                      selected: _favoriteDishes,
                      onChanged: (v) => _favoriteDishes
                        ..clear()
                        ..addAll(v),
                    ),
                  ),
                  if (_favoriteDishes.isNotEmpty) ...[
                    SizedBox(height: 10),
                    _SelectedChips(
                      items: _favoriteDishes,
                      onRemove: (item) =>
                          setState(() => _favoriteDishes.remove(item)),
                    ),
                  ],
                  SizedBox(height: 28),

                  // ── الطبخات غير المفضلة ───────────────────────────
                  _SectionLabel('الأطباق التي لا تفضلها العائلة'),
                  SizedBox(height: 4),
                  _SectionSubLabel('ما تريد استثناءه من الخطة الأسبوعية'),
                  SizedBox(height: 10),
                  _SearchTrigger(
                    hint: 'ابحث عن طبق...',
                    count: _dislikedDishes.length,
                    onTap: () => _openSearch(
                      title: 'أطباق غير مفضلة',
                      hint: 'ابحث: بامية، فاصولياء...',
                      pool: _kDishes,
                      selected: _dislikedDishes,
                      onChanged: (v) => _dislikedDishes
                        ..clear()
                        ..addAll(v),
                    ),
                  ),
                  if (_dislikedDishes.isNotEmpty) ...[
                    SizedBox(height: 10),
                    _SelectedChips(
                      items: _dislikedDishes,
                      onRemove: (item) =>
                          setState(() => _dislikedDishes.remove(item)),
                    ),
                  ],
                  SizedBox(height: 18),
                  Divider(
                    color: Colors.grey.withOpacity(0.3), // لون شبه شفاف
                    thickness: 1,
                    height: 13,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SizedBox(height: 18),
                  // ── المكونات غير المفضلة ──────────────────────────
                  _SectionLabel('المكونات التي لا تفضلها العائلة'),
                  SizedBox(height: 4),
                  _SectionSubLabel('مكونات لا تريد رؤيتها في وجباتك'),
                  SizedBox(height: 10),
                  _SearchTrigger(
                    hint: 'ابحث عن مكون...',
                    count: _dislikedIngredients.length,
                    onTap: () => _openSearch(
                      title: 'مكونات غير مفضلة',
                      hint: 'ابحث: باذنجان، كزبرة...',
                      pool: _kIngredients,
                      selected: _dislikedIngredients,
                      onChanged: (v) => _dislikedIngredients
                        ..clear()
                        ..addAll(v),
                    ),
                  ),
                  if (_dislikedIngredients.isNotEmpty) ...[
                    SizedBox(height: 10),
                    _SelectedChips(
                      items: _dislikedIngredients,
                      onRemove: (item) =>
                          setState(() => _dislikedIngredients.remove(item)),
                    ),
                  ],
                  SizedBox(height: 28),

                  // ── الحساسية الغذائية ─────────────────────────────
                  _SectionLabel('الحساسية الغذائية'),
                  SizedBox(height: 4),
                  _SectionSubLabel('اختر إن وجد لديك حساسية'),
                  SizedBox(height: 10),
                  _SearchTrigger(
                    hint: 'ابحث عن حساسية...',
                    count: _allergies.length,
                    onTap: () => _openSearch(
                      title: 'الحساسية الغذائية',
                      hint: 'ابحث: مكسرات، لبن...',
                      pool: _kAllergies,
                      selected: _allergies,
                      onChanged: (v) => _allergies
                        ..clear()
                        ..addAll(v),
                    ),
                  ),
                  if (_allergies.isNotEmpty) ...[
                    SizedBox(height: 10),
                    _SelectedChips(
                      items: _allergies,
                      color: AppColors.error,
                      onRemove: (item) =>
                          setState(() => _allergies.remove(item)),
                    ),
                  ],
                  SizedBox(height: 18),
                  Divider(
                    color: Colors.grey.withOpacity(0.3), // لون شبه شفاف
                    thickness: 1,
                    height: 13,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SizedBox(height: 18),
                  // ── تفضيل الطبخ ───────────────────────────────────
                  _SectionLabel('هل تفضل الطبخ على يومين أم يوم واحد؟'),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceOptionCard(
                          label: 'يوم واحد',
                          subtitle: 'طبخ كل وجبة بيومها',
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
                          isSelected: _cookingFrequency == 'يومين',
                          onTap: () =>
                              setState(() => _cookingFrequency = 'يومين'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Divider(
                    color: Colors.grey.withOpacity(0.3), // لون شبه شفاف
                    thickness: 1,
                    height: 13,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SizedBox(height: 18),
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
                        _SearchTrigger(
                          hint: 'ابحث عن مكون...',
                          count: _dislikedIngredients.length,
                          onTap: () => _openSearch(
                            title: "مكونات متوفرة بشكل كامل",
                            hint: 'مثلاً: دبس رمان',
                            pool: _kIngredients,
                            selected: _dislikedIngredients,
                            onChanged: (v) => _dislikedIngredients
                              ..clear()
                              ..addAll(v),
                          ),
                        ),
                        if (_dislikedIngredients.isNotEmpty) ...[
                          SizedBox(height: 10),
                          _SelectedChips(
                            items: _dislikedIngredients,
                            onRemove: (item) => setState(
                                () => _dislikedIngredients.remove(item)),
                          ),
                        ],
                        SizedBox(height: 28),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  Divider(
                    color: Colors.grey.withOpacity(0.3), // لون شبه شفاف
                    thickness: 1,
                    height: 13,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SizedBox(height: 18),
                  // ── أيام الديليفري ────────────────────────────────
                  _SectionLabel('كم يوماً في الأسبوع تطلبون فيه ديليفري؟'),
                  SizedBox(height: 12),
                  _CounterCard(
                    value: _deliveryDays,
                    unit: 'أيام / أسبوع',
                    onDecrement: () => setState(() {
                      if (_deliveryDays > 0) _deliveryDays--;
                    }),
                    onIncrement: () => setState(() {
                      if (_deliveryDays < 6) _deliveryDays++;
                    }),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
      );
}

class _SectionSubLabel extends StatelessWidget {
  final String text;
  const _SectionSubLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
      );
}

class _CounterCard extends StatelessWidget {
  final int value;
  final String unit;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CounterCard({
    required this.value,
    required this.unit,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: Icon(Icons.remove_circle_outline_rounded,
                color: AppColors.accentLight, size: 30),
          ),
          Column(
            children: [
              Text(
                '$value',
                style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent),
              ),
              Text(unit,
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          IconButton(
            onPressed: onIncrement,
            icon: Icon(Icons.add_circle_outline_rounded,
                color: AppColors.accentLight, size: 30),
          ),
        ],
      ),
    );
  }
}

/// The tappable field that opens the search sheet
class _SearchTrigger extends StatelessWidget {
  final String hint;
  final int count;
  final VoidCallback onTap;

  const _SearchTrigger(
      {required this.hint, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 20, color: AppColors.textHint),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                style:
                    GoogleFonts.cairo(fontSize: 14, color: AppColors.textHint),
              ),
            ),
            if (count > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count محدد',
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chips showing selected items under the search trigger
class _SelectedChips extends StatelessWidget {
  final Set<String> items;
  final Color color;
  final void Function(String) onRemove;

  const _SelectedChips({
    required this.items,
    this.color = AppColors.accent,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: EdgeInsets.only(right: 12, left: 6, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item,
                style: GoogleFonts.cairo(
                    fontSize: 13, color: color, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 6),
              GestureDetector(
                onTap: () => onRemove(item),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 12, color: color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Searchable bottom sheet ────────────────────────────────────────────────────

class _SearchableSelectionSheet extends StatefulWidget {
  final String title;
  final String hint;
  final List<String> pool;
  final Set<String> initialSelected;

  const _SearchableSelectionSheet({
    required this.title,
    required this.hint,
    required this.pool,
    required this.initialSelected,
  });

  @override
  State<_SearchableSelectionSheet> createState() =>
      _SearchableSelectionSheetState();
}

class _SearchableSelectionSheetState extends State<_SearchableSelectionSheet> {
  late Set<String> _selected;
  late List<String> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
    _filtered = List.from(widget.pool);
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(widget.pool)
          : widget.pool
              .where((item) => item.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        margin: EdgeInsets.only(bottom: bottomInset),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 14),

            // Title row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.cairo(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (_selected.isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selected.length} محدد',
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.accentLight,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 14),

            // Search field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: GoogleFonts.cairo(fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: GoogleFonts.cairo(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        30), // كلما زاد الرقم صار أكثر كروية
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey
                          .shade300, // أو AppColors.primary إذا أردته يتغير عند الضغط
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),

            Divider(height: 1, color: AppColors.divider),

            // Results list
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 40, color: AppColors.textHint),
                          SizedBox(height: 10),
                          Text(
                            'لا توجد نتائج',
                            style: GoogleFonts.cairo(
                                color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => Divider(
                          height: 1, color: AppColors.divider, indent: 20),
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        final isSelected = _selected.contains(item);
                        return ListTile(
                          onTap: () => setState(() {
                            if (isSelected) {
                              _selected.remove(item);
                            } else {
                              _selected.add(item);
                            }
                          }),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          title: Text(
                            item,
                            style: GoogleFonts.cairo(
                              fontSize: 14.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
                            ),
                          ),
                          trailing: AnimatedContainer(
                            duration: Duration(milliseconds: 180),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.accent
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.divider,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                        );
                      },
                    ),
            ),

            // Confirm button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _selected.isEmpty
                          ? 'تخطي'
                          : 'تأكيد (${_selected.length})',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
