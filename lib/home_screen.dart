// ignore_for_file: unused_element, unused_local_variable, prefer_const_constructors, deprecated_member_use, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sho_htghadona/features/auth/bloc/auth_cubit.dart';
import 'package:sho_htghadona/features/auth/bloc/auth_state.dart';
import 'package:sho_htghadona/features/family/screens/family_info_screen.dart';
import '../features/family/bloc/family_bloc.dart';
import '../features/meal_request/screens/meal_request_screen.dart';
import '../features/meal_history/bloc/meal_history_bloc.dart';
import '../features/meal_history/models/plan_history_model.dart';
import '../features/meal_history/screens/meal_history_screen.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // مفتاح يتغيّر كل مرة نفتح فيها تبويب "الخطة" قادمين من تبويب آخر،
  // حتى يبني فلاتر MealRequestScreen من جديد (فورم فاضي كل مرة) بدل
  // الاحتفاظ بنفس الحالة القديمة بسبب IndexedStack.
  int _mealRequestResetKey = 0;

  List<Widget> get _pages => [
        const _DashboardTab(),
        MealRequestScreen(key: ValueKey(_mealRequestResetKey)),
        const MealHistoryScreen(),
        const _ProfileTab(),
      ];

  void _onTabSelected(int index) {
    setState(() {
      if (index == 1 && _currentIndex != 1) {
        _mealRequestResetKey++;
      }
      _currentIndex = index;
    });
  }

  /// نفس منطق تبديل التبويب أعلاه، مكشوف للاستخدام من الأزرار الداخلية
  /// (مثل زر "ابدأ الآن" وبطاقة "لا توجد وجبات محفوظة") حتى لا تفوّت
  /// إعادة تعيين فورم طلب الخطة عند الانتقال إليه من مكان غير الشريط
  /// السفلي مباشرة.
  void switchToTab(int index) => _onTabSelected(index);

  @override
  void initState() {
    super.initState();
    context.read<MealHistoryBloc>().add(const HistoryRequested());
    context.read<FamilyBloc>().add(FamilyProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
                top: BorderSide(color: AppColors.divider.withOpacity(0.6))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 64,
              indicatorColor: AppColors.primary.withOpacity(0.12),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: AppColors.textHint),
                  selectedIcon:
                      Icon(Icons.home_rounded, color: AppColors.primary),
                  label: 'الرئيسية',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined,
                      color: AppColors.textHint),
                  selectedIcon: Icon(Icons.calendar_month_rounded,
                      color: AppColors.primary),
                  label: 'الخطة',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined, color: AppColors.textHint),
                  selectedIcon:
                      Icon(Icons.history_rounded, color: AppColors.primary),
                  label: 'السجل',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded,
                      color: AppColors.textHint),
                  selectedIcon:
                      Icon(Icons.person_rounded, color: AppColors.primary),
                  label: 'الملف',
                ),
              ],
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthSuccess ? authState.user : null;
        final firstName = (user?.name ?? 'صديقنا').split(' ').first;

        return BlocBuilder<MealHistoryBloc, MealHistoryState>(
          builder: (context, histState) {
            final recentPlans = histState.listStatus == AsyncStatus.success
                ? histState.plans.take(3).toList()
                : <PlanSummary>[];
            // مجموع عدد الوجبات عبر كل الخطط المحفوظة
            final mealsCount =
                histState.plans.fold<int>(0, (sum, p) => sum + p.numberOfMeals);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ───────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 45, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Hero Slider: App Benefits ───────────
                      _HeroBenefitsSlider(
                        onTap: () {
                          final homeState = context
                              .findAncestorStateOfType<_HomeScreenState>();
                          homeState?.switchToTab(1);
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Stats row ──────────────────────────────
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: _StatTile(
                      //         icon: Icons.restaurant_rounded,
                      //         value: '$mealsCount',
                      //         label: 'وجبة محفوظة',
                      //       ),
                      //     ),
                      //     const SizedBox(width: 12),
                      //     Expanded(
                      //       child: _StatTile(
                      //         icon: Icons.payments_outlined,
                      //         value: '250',
                      //         label: 'متوسط ل.س / وجبة',
                      //       ),
                      //     ),
                      //     const SizedBox(width: 12),
                      //     Expanded(
                      //       child: _StatTile(
                      //         icon: Icons.timer_outlined,
                      //         value: '٣٥',
                      //         label: 'دقيقة بالمتوسط',
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 10),

                      // ── Tips ───────────────────────────────────
                      _TipCard(
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'وفّر وقتك',
                        body:
                            'جهّز المقادير مسبقًا قبل البدء بالطبخ لتقليل الفوضى وتسريع التحضير.',
                      ),
                      const SizedBox(height: 8),
                      _TipCard(
                        icon: Icons.restaurant_menu_rounded,
                        title: 'وصفات متنوعة',
                        body:
                            'استكشف أكثر من 100 طبخة متنوعة تناسب جميع الأذواق والمناسبات.',
                      ),
                      const SizedBox(height: 17),

                      // ── Recent meals ───────────────────────────
                      if (recentPlans.isNotEmpty) ...[
                        SectionHeader(
                          title: 'آخر الخطط',
                          trailing: TextButton(
                            onPressed: () {
                              final homeState = context
                                  .findAncestorStateOfType<_HomeScreenState>();
                              homeState?.switchToTab(2);
                            },
                            child: Text(
                              'عرض الكل',
                              style: GoogleFonts.cairo(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...recentPlans.map((plan) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _RecentMealTile(plan: plan),
                            )),
                      ] else
                        _NoMealsYetCard(
                          onTap: () {
                            final homeState = context
                                .findAncestorStateOfType<_HomeScreenState>();
                            homeState?.switchToTab(1);
                          },
                        ),

                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Hero Benefits Slider (التصميم الحديث للقسم الأعلى) ────────────────────────

class _HeroBenefitsSlider extends StatefulWidget {
  final VoidCallback onTap;
  const _HeroBenefitsSlider({required this.onTap});

  @override
  State<_HeroBenefitsSlider> createState() => _HeroBenefitsSliderState();
}

class _HeroBenefitsSliderState extends State<_HeroBenefitsSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  // 🎨 تم ربط القائمة بألوان AppColors المعتمدة في التطبيق
  List<Map<String, dynamic>> get _slides => [
        {
          'badge': 'توفير وميزانية',
          'title': 'وجبات تناسب ميزانيتك',
          'subtitle':
              'خطط لوجبات أسبوعية مرنة واقتصادية تجنبك الهدر المالي والمصاريف الزائدة.',
          'icon': Icons.account_balance_wallet_rounded,
          'gradient': [
            AppColors.accent,
            AppColors.accentLight
          ], // تدرج الأخضر الزمردي المنعش
          'accentColor': AppColors.cardBg,
        },
        {
          'badge': 'صحة وتغذية',
          'title': 'أكل مراعي للعناصر الغذائية',
          'subtitle':
              'اقتراحات متوازنة تضمن حصول عائلتك على العناصر الغذائية اللازمة يومياً.',
          'icon': Icons.health_and_safety_rounded,
          'gradient': [
            AppColors.accent,
            AppColors.accentLight
          ], // تدرج الأخضر الزمردي المنعش
          'accentColor': AppColors.cardBg,
        },
        {
          'badge': 'استغلال المكونات',
          'title': 'طبخ أسهل بالمكونات المتاحة',
          'subtitle':
              'استغل المواد الموجودة في مطبخك حالياً وحولها إلى وجبات شهية بكل سهولة.',
          'icon': Icons.kitchen_rounded,
          'gradient': [
            AppColors.accent,
            AppColors.accentLight
          ], // تدرج الأخضر الزمردي المنعش
          'accentColor': AppColors.cardBg,
        },
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    return Column(
      children: [
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: _SlideCard(
                  slide: slide,
                  onTap: widget.onTap,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: _currentPage == index ? 22 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideCard extends StatelessWidget {
  final Map<String, dynamic> slide;
  final VoidCallback onTap;

  const _SlideCard({
    required this.slide,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = slide['gradient'] as List<Color>;
    final Color accentColor = slide['accentColor'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            // Decorative floating circles
            Positioned(
              left: -30,
              top: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              right: -20,
              bottom: -40,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Badge & Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              slide['icon'] as IconData,
                              size: 13,
                              color: accentColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              slide['badge'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          slide['icon'] as IconData,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  // Middle: Title & Subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide['title'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slide['subtitle'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          color: Colors.white.withOpacity(0.92),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  // Bottom: CTA Link
                  Row(
                    children: [
                      Text(
                        'ابدأ الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 12,
                        color: accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact stat tile used in the dashboard stats row.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.textPrimary),
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

/// Tip card with an icon badge instead of a raw emoji for a cleaner look.
class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _TipCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent plan tile shown in the dashboard's "آخر الخطط" list.
/// (كانت سابقًا تعرض وجبة مفردة MealModel، وأصبحت تعرض ملخص خطة PlanSummary
/// لأن /api/plans يرجع خططًا لا وجبات مفردة - نفس التصميم البصري بالضبط).
class _RecentMealTile extends StatelessWidget {
  final PlanSummary plan;
  const _RecentMealTile({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${plan.numberOfMeals} وجبات لـ ${plan.servings} ${plan.servings == 1 ? "شخص" : "أشخاص"}',
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3),
                Text(
                  plan.prepTime,
                  style: GoogleFonts.cairo(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty-state card shown when there are no saved meals yet.
class _NoMealsYetCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NoMealsYetCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant_menu_rounded,
                size: 26, color: AppColors.textSecondary),
          ),
          SizedBox(height: 14),
          Text(
            'لا توجد وجبات محفوظة بعد',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'ابدأ بإنشاء خطة وجبات لتظهر هنا',
            style: GoogleFonts.cairo(
                fontSize: 12.5, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'إنشاء خطة وجبات',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Tab

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  void _showLogoutConfirmDialog(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
            ),
            content: Text(
              'هل أنت متأكد أنك تريد تسجيل الخروج؟',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<FamilyBloc>().add(FamilyReset());
                  authCubit.logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'تسجيل الخروج',
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthSuccess ? authState.user : null;

        return BlocBuilder<FamilyBloc, FamilyState>(
          builder: (context, familyState) {
            final family =
                familyState is FamilyLoaded ? familyState.family : null;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (family != null) ...[
                        _ProfileSection(title: 'معلومات العائلة', children: [
                          _ProfileRow(
                              icon: Icons.group_rounded,
                              label: 'عدد الأفراد',
                              value: '${family.memberCount} أفراد'),
                          // _ProfileRow(
                          //     icon: Icons.calendar_view_week_outlined,
                          //     label: 'تكرار الطبخ',
                          //     value: family.cookingFrequency),
                          // _ProfileRow(
                          //     icon: Icons.delivery_dining_outlined,
                          //     label: 'أيام الديليفري',
                          //     value:
                          // '${family.deliveryDaysPerWeek} أيام / أسبوع'),
                          if (family.favoriteDishes.isNotEmpty)
                            _ProfileRow(
                                icon: Icons.favorite_outline_rounded,
                                label: 'الأكلات المفضلة',
                                value: family.favoriteDishes.join('، ')),
                          if (family.allergies.isNotEmpty)
                            _ProfileRow(
                                icon: Icons.warning_amber_rounded,
                                label: 'الحساسية',
                                value: family.allergies.join('، '),
                                valueColor: AppColors.error),
                          if (family.dislikedIngredients.isNotEmpty)
                            _ProfileRow(
                                icon: Icons.block_rounded,
                                label: 'مكونات غير مفضلة',
                                value: family.dislikedIngredients.join('، ')),
                          if (family.dislikedDishes.isNotEmpty)
                            _ProfileRow(
                                icon: Icons.do_not_disturb_alt_rounded,
                                label: 'أطباق غير مفضلة',
                                value: family.dislikedDishes.join('، ')),
                        ]),
                        SizedBox(height: 16),
                      ],
                      _ProfileSection(title: 'الحساب', children: [
                        ListTile(
                            leading: Icon(Icons.family_restroom_rounded,
                                color: AppColors.accent),
                            title: Text('تعديل معلومات العائلة',
                                style: GoogleFonts.cairo(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            trailing: Icon(Icons.arrow_back_ios_rounded,
                                size: 14, color: AppColors.textHint),
                            contentPadding: EdgeInsets.symmetric(horizontal: 4),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<FamilyBloc>(),
                                    child:
                                        FamilyInfoScreen(initialFamily: family),
                                  ),
                                ),
                              );
                            }),
                        Divider(color: AppColors.divider, height: 1),
                        ListTile(
                          leading: Icon(Icons.logout_rounded,
                              color: AppColors.error),
                          title: Text('تسجيل الخروج',
                              style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 4),
                          onTap: () {
                            // print(' تم الضغط على تسجيل الخروج');
                            _showLogoutConfirmDialog(context);
                          },
                        ),
                      ]),
                      SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 14, color: AppColors.textSecondary)),
          ),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
