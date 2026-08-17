// ignore_for_file: prefer_const_constructors, deprecated_member_use, unused_element, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/family_bloc.dart';
import '../models/family_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/services/search_api_service.dart';

enum _SearchType { meals, ingredients, allergies }

class FamilyInfoScreen extends StatefulWidget {
  final FamilyModel? initialFamily;

  const FamilyInfoScreen({super.key, this.initialFamily});

  @override
  State<FamilyInfoScreen> createState() => _FamilyInfoScreenState();
}

class _FamilyInfoScreenState extends State<FamilyInfoScreen> {
  int _memberCount = 4;

  final Set<String> _favoriteDishes = {};
  final Set<String> _dislikedDishes = {};
  final Set<String> _dislikedIngredients = {};
  final Set<String> _availableBasics = {};
  final Set<String> _allergies = {};

  bool get _isEditMode => widget.initialFamily != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialFamily;
    if (initial != null) {
      _memberCount = initial.memberCount;
      _favoriteDishes.addAll(initial.favoriteDishes);
      _dislikedDishes.addAll(initial.dislikedDishes);
      _dislikedIngredients.addAll(initial.dislikedIngredients);
      _allergies.addAll(initial.allergies);
      _availableBasics.addAll(initial.availableBasicIngredients);
    }
  }

  void _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدث خطأ ما يُرجى إعادة المحاولة"),
        ),
      );
      return;
    }

    final family = FamilyModel(
      memberCount: _memberCount,
      favoriteDishes: _favoriteDishes.toList(),
      dislikedDishes: _dislikedDishes.toList(),
      dislikedIngredients: _dislikedIngredients.toList(),
      allergies: _allergies.toList(),
      availableBasicIngredients: _availableBasics.toList(),
    );
    if (_isEditMode) {
      context.read<FamilyBloc>().add(
            FamilyInfoEdited(family: family, token: token),
          );
    } else {
      context.read<FamilyBloc>().add(
            FamilyInfoSubmitted(family: family, token: token),
          );
    }
  }

  Future<void> _openSearch({
    required String title,
    required String hint,
    required _SearchType searchType,
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
        searchType: searchType,
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
          title: Text(_isEditMode
              ? 'تعديل معلومات العائلة'
              : 'معلومات العائلة'), 
          centerTitle: false,
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
    icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
    onPressed: () {
      if (_isEditMode) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }})
        ),
        body: BlocConsumer<FamilyBloc, FamilyState>(
          listener: (context, state) {
            if (state is FamilyLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              );
            }

            if (state is FamilySuccess) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.accent,
                ),
              );
              if (_isEditMode) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            }

            if (state is FamilyFailure) {

              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  _sep(),
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
                      searchType: _SearchType.meals,
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
                      onRemove: (i) =>
                          setState(() => _favoriteDishes.remove(i)),
                    ),
                  ],
                  SizedBox(height: 28),
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
                      searchType: _SearchType.meals,
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
                      onRemove: (i) =>
                          setState(() => _dislikedDishes.remove(i)),
                    ),
                  ],
                  _sep(),
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
                      searchType: _SearchType.ingredients,
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
                      onRemove: (i) =>
                          setState(() => _dislikedIngredients.remove(i)),
                    ),
                  ],
                  SizedBox(height: 28),
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
                      searchType: _SearchType.allergies,
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
                      onRemove: (i) => setState(() => _allergies.remove(i)),
                    ),
                  ],
                  _sep(),
                  _SectionCard(
                    icon: Icons.help_outline_rounded,
                    title: 'سؤال مهم',
                    iconColor: AppColors.accentLight,
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
                          count: _availableBasics.length,
                          onTap: () => _openSearch(
                            title: 'مكونات متوفرة بشكل كامل',
                            hint: 'مثلاً: دبس رمان',
                            searchType: _SearchType.ingredients,
                            selected: _availableBasics,
                            onChanged: (v) => _availableBasics
                              ..clear()
                              ..addAll(v),
                          ),
                        ),
                        if (_availableBasics.isNotEmpty) ...[
                          SizedBox(height: 10),
                          _SelectedChips(
                            items: _availableBasics,
                            onRemove: (i) =>
                                setState(() => _availableBasics.remove(i)),
                          ),
                        ],
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                  SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: _isEditMode
                          ? 'حفظ التعديلات'
                          : 'حفظ و متابعة', // << عدّل
                      onPressed: _submit,
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

  Widget _sep() => Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Divider(
          color: Colors.grey.withOpacity(0.3),
          thickness: 1,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
      );
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
              Text('$value',
                  style: GoogleFonts.cairo(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent)),
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
              child: Text(hint,
                  style: GoogleFonts.cairo(
                      fontSize: 14, color: AppColors.textHint)),
            ),
            if (count > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$count محدد',
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}

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
              Text(item,
                  style: GoogleFonts.cairo(
                      fontSize: 13, color: color, fontWeight: FontWeight.w600)),
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

//  Search Sheet

class _SearchableSelectionSheet extends StatefulWidget {
  final String title;
  final String hint;
  final _SearchType searchType;
  final Set<String> initialSelected;

  const _SearchableSelectionSheet({
    required this.title,
    required this.hint,
    required this.searchType,
    required this.initialSelected,
  });

  @override
  State<_SearchableSelectionSheet> createState() =>
      _SearchableSelectionSheetState();
}

class _SearchableSelectionSheetState extends State<_SearchableSelectionSheet> {
  late Set<String> _selected;
  List<String> _results = [];
  final _searchCtrl = TextEditingController();

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMsg = '';
  bool _didSearch = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
    _searchCtrl.addListener(_onTyping);
  }

  void _onTyping() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _results = [];
        _isLoading = false;
        _hasError = false;
        _didSearch = false;
      });
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 400), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _didSearch = true;
    });

    ApiResult<List<String>> result;

    switch (widget.searchType) {
      case _SearchType.meals:
        result = await SearchApiService.searchMeals(q);
        break;
      case _SearchType.ingredients:
      case _SearchType.allergies:
        result = await SearchApiService.searchIngredients(q);
        break;
    }

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _results = result.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasError = true;
        _errorMsg = result.error!;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.title,
                        style: GoogleFonts.cairo(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                  if (_selected.isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_selected.length} محدد',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.accentLight,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
            SizedBox(height: 14),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: GoogleFonts.cairo(fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: GoogleFonts.cairo(
                      color: AppColors.textHint, fontSize: 14),
                  prefixIcon: _isLoading
                      ? Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.textHint),
                          ),
                        )
                      : Icon(Icons.search_rounded, color: AppColors.textHint),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              size: 18, color: AppColors.textHint),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            SizedBox(height: 12),
            Divider(height: 1, color: AppColors.divider),
            Expanded(child: _buildBody()),
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
                          color: Colors.white),
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

  Widget _buildBody() {
    if (!_didSearch) {
      return Center(
        child: Text('اكتب للبحث',
            style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textHint)),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.textHint),
            SizedBox(height: 10),
            Text(_errorMsg,
                style: GoogleFonts.cairo(
                    fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            SizedBox(height: 14),
            TextButton(
              onPressed: () => _search(_searchCtrl.text.trim()),
              child: Text('إعادة المحاولة',
                  style: GoogleFonts.cairo(color: AppColors.accent)),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: AppColors.textHint),
            SizedBox(height: 10),
            Text('لا توجد نتائج',
                style: GoogleFonts.cairo(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: AppColors.divider, indent: 20),
      itemBuilder: (context, index) {
        final item = _results[index];
        final isSelected = _selected.contains(item);
        return ListTile(
          onTap: () => setState(() {
            if (isSelected) {
              _selected.remove(item);
            } else {
              _selected.add(item);
            }
          }),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          title: Text(
            item,
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
          trailing: AnimatedContainer(
            duration: Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.accent : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.divider,
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
        );
      },
    );
  }
}
