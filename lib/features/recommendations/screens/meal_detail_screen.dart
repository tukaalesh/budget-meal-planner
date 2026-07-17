// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/meal_model.dart';
// import '../../../core/theme/app_theme.dart';

// class MealDetailScreen extends StatelessWidget {
//   final MealModel meal;
//   const MealDetailScreen({super.key, required this.meal});

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         body: CustomScrollView(
//           slivers: [
//             SliverAppBar(
//               pinned: true,
//               expandedHeight: 140,
//               backgroundColor: AppColors.surface,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         AppColors.primary.withOpacity(0.12),
//                         AppColors.secondary.withOpacity(0.16),
//                       ],
//                       begin: Alignment.topRight,
//                       end: Alignment.bottomLeft,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(height: 10),
//                       // Text(meal.imageEmoji, style: TextStyle(fontSize: 80)),
//                       SizedBox(height: 8),
//                       Text(
//                         meal.name,
//                         style: GoogleFonts.cairo(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w800,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SliverPadding(
//               padding: EdgeInsets.all(20),
//               sliver: SliverList(
//                 delegate: SliverChildListDelegate([
//                   Row(
//                     children: [
//                       _DetailStat(
//                         icon: Icons.timer_outlined,
//                         label: 'وقت الطهي',
//                         value: '${meal.cookingTimeMinutes} دقيقة',
//                         color: AppColors.secondary,
//                       ),
//                       SizedBox(width: 12),
//                       _DetailStat(
//                         icon: Icons.group_outlined,
//                         label: 'يكفي لـ',
//                         value: '${meal.servings} أشخاص',
//                         color: AppColors.accent,
//                       ),
//                       SizedBox(width: 12),
//                       _DetailStat(
//                         icon: Icons.money_rounded,
//                         label: 'التكلفة',
//                         value: '${meal.estimatedCost.round()} ل.س',
//                         color: AppColors.primary,
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: AppColors.secondary.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.star_rounded,
//                                 color: AppColors.secondary, size: 18),
//                             SizedBox(width: 6),
//                             Text(
//                               '${meal.rating} / 5',
//                               style: GoogleFonts.cairo(
//                                 fontWeight: FontWeight.w700,
//                                 color: AppColors.secondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.signal_cellular_alt_rounded,
//                                 color: AppColors.primary, size: 16),
//                             SizedBox(width: 6),
//                             Text(
//                               'مستوى: ${meal.difficulty}',
//                               style: GoogleFonts.cairo(
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.primary,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   _DetailSection(
//                     title: 'وصف الطبق',
//                     icon: Icons.info_outline_rounded,
//                     child: Text(
//                       meal.description,
//                       style: GoogleFonts.cairo(
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                         height: 1.8,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   _DetailSection(
//                     title: 'المقادير الكاملة',
//                     icon: Icons.kitchen_rounded,
//                     child: Column(
//                       children: meal.ingredients.asMap().entries.map((entry) {
//                         final isMissing =
//                             meal.missingIngredients.contains(entry.value);
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: 5),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 28,
//                                 height: 28,
//                                 decoration: BoxDecoration(
//                                   color: isMissing
//                                       ? AppColors.warning.withOpacity(0.12)
//                                       : AppColors.success.withOpacity(0.12),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   isMissing
//                                       ? Icons.shopping_cart_outlined
//                                       : Icons.check_rounded,
//                                   size: 15,
//                                   color: isMissing
//                                       ? AppColors.warning
//                                       : AppColors.success,
//                                 ),
//                               ),
//                               SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   entry.value,
//                                   style: GoogleFonts.cairo(
//                                     fontSize: 14,
//                                     color: isMissing
//                                         ? AppColors.warning
//                                         : AppColors.textPrimary,
//                                     fontWeight: isMissing
//                                         ? FontWeight.w600
//                                         : FontWeight.w400,
//                                   ),
//                                 ),
//                               ),
//                               if (isMissing)
//                                 Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.warning.withOpacity(0.12),
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Text(
//                                     'ناقص',
//                                     style: GoogleFonts.cairo(
//                                       fontSize: 10,
//                                       color: AppColors.warning,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                   if (meal.missingIngredients.isNotEmpty) ...[
//                     SizedBox(height: 16),
//                     Container(
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: AppColors.warning.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                             color: AppColors.warning.withOpacity(0.3)),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline_rounded,
//                               color: AppColors.warning, size: 20),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               'عند قبول هذه الوجبة ستحصل على قائمة تسوق تلقائية للمقادير الناقصة.',
//                               style: GoogleFonts.cairo(
//                                 fontSize: 13,
//                                 color: AppColors.warning,
//                                 height: 1.5,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   SizedBox(height: 40),
//                 ]),
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: ElevatedButton.icon(
//               onPressed: () => Navigator.of(context).pop(),
//               icon: Icon(Icons.check_circle_outline_rounded),
//               label: Text('قبول هذه الوجبة',
//                   style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
//               style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 52)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _DetailStat extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;

//   const _DetailStat({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 22),
//             SizedBox(height: 6),
//             Text(
//               value,
//               style: GoogleFonts.cairo(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 2),
//             Text(
//               label,
//               style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textHint),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DetailSection extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Widget child;

//   const _DetailSection(
//       {required this.title, required this.icon, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.cardBg,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.divider),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 18, color: AppColors.primary),
//               SizedBox(width: 8),
//               Text(title, style: Theme.of(context).textTheme.titleMedium),
//             ],
//           ),
//           SizedBox(height: 14),
//           child,
//         ],
//       ),
//     );
//   }
// }
