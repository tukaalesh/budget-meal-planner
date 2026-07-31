import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/meal_history_bloc.dart';
import '../../recommendations/models/meal_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class MealHistoryScreen extends StatelessWidget {
  const MealHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text('سجل الوجبات'),
          actions: [
            BlocBuilder<MealHistoryBloc, MealHistoryState>(
              builder: (context, state) {
                if (state is MealHistoryLoadedState && state.meals.isNotEmpty) {
                  return IconButton(
                    icon: Icon(Icons.delete_sweep_outlined,
                        color: AppColors.textSecondary),
                    tooltip: 'مسح السجل',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: Text('مسح السجل',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w700)),
                            content: Text('هل تريد مسح سجل الوجبات كاملاً؟',
                                style: GoogleFonts.cairo()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child:
                                    Text('إلغاء', style: GoogleFonts.cairo()),
                              ),
                              ElevatedButton(
                                
                                onPressed: () {
                                  context
                                      .read<MealHistoryBloc>()
                                      .add(MealHistoryCleared());
                                  Navigator.pop(context);
                                },
                                child: Text('مسح',
                                    style:
                                        GoogleFonts.cairo(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<MealHistoryBloc, MealHistoryState>(
          builder: (context, state) {
            if (state is MealHistoryInitial) {
              return Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }

            final meals =
                state is MealHistoryLoadedState ? state.meals : <MealModel>[];

            if (meals.isEmpty) {
              return EmptyState(
                icon: Icons.history_rounded,
                title: 'لا يوجد سجل بعد',
                subtitle: 'الوجبات التي تحفظها من خطتك الأسبوعية تظهر هنا',
              );
            }

            // Group total stats
            final totalCost =
                meals.fold<double>(0, (sum, m) => sum + m.estimatedCost);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        _StatChip(
                          icon: Icons.restaurant_menu_rounded,
                          label: '${meals.length} وجبة محفوظة',
                        ),
                        SizedBox(width: 10),
                        _StatChip(
                          icon: Icons.payments_outlined,
                          label: '${totalCost.round()} ل.س إجمالي',
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final meal = meals[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _HistoryCard(
                              meal: meal, isRecent: index == 0, onTap: () {}
                              //  =>
                              //  Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //       builder: (_) => MealDetailScreen(meal: meal)),
                              // ),
                              ),
                        );
                      },
                      childCount: meals.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final MealModel meal;
  final bool isRecent;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.meal,
    required this.isRecent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasMissing = meal.missingIngredients.isNotEmpty;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRecent
                  ? AppColors.primary.withOpacity(0.25)
                  : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              // Container(
              //   width: 56,
              //   height: 56,
              //   decoration: BoxDecoration(
              //     color: AppColors.surfaceVariant,
              //     borderRadius: BorderRadius.circular(14),
              //   ),
              //   child: Center(
              //     child: Text(meal.imageEmoji, style: TextStyle(fontSize: 28)),
              //   ),
              // ),
              // SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isRecent) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'الأحدث',
                              style: GoogleFonts.cairo(
                                fontSize: 9.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            meal.name,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.payments_outlined,
                            size: 12, color: AppColors.textHint),
                        SizedBox(width: 3),
                        Text(
                          '${meal.estimatedCost.round()} ل.س',
                          style: GoogleFonts.cairo(
                              fontSize: 11.5, color: AppColors.textHint),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          hasMissing
                              ? Icons.shopping_cart_outlined
                              : Icons.check_circle_outline_rounded,
                          size: 12,
                          color: AppColors.textHint,
                        ),
                        SizedBox(width: 3),
                        Text(
                          hasMissing
                              ? '${meal.missingIngredients.length} ناقصة'
                              : 'مكتملة',
                          style: GoogleFonts.cairo(
                              fontSize: 11.5, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios_rounded,
                  size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
