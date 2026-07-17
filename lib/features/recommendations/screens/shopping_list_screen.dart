// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/meal_model.dart';
// import '../../meal_history/bloc/meal_history_bloc.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/widgets/app_widgets.dart';

// class ShoppingListScreen extends StatefulWidget {
//   final MealModel meal;
//   final List<String> shoppingList;

//   const ShoppingListScreen({
//     super.key,
//     required this.meal,
//     required this.shoppingList,
//   });

//   @override
//   State<ShoppingListScreen> createState() => _ShoppingListScreenState();
// }

// class _ShoppingListScreenState extends State<ShoppingListScreen> {
//   final Set<String> _checkedItems = {};
//   bool _savedToHistory = false;

//   void _saveToHistory() {
//     context.read<MealHistoryBloc>().add(MealHistoryAdded(widget.meal));
//     setState(() => _savedToHistory = true);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
//             SizedBox(width: 10),
//             Text('تم حفظ الوجبة في السجل!', style: GoogleFonts.cairo()),
//           ],
//         ),
//         backgroundColor: AppColors.success,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hasItems = widget.shoppingList.isNotEmpty;
//     final allChecked =
//         hasItems && _checkedItems.length == widget.shoppingList.length;

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: Text('قائمة التسوق'),
//           actions: [
//             if (!_savedToHistory)
//               TextButton.icon(
//                 onPressed: _saveToHistory,
//                 icon:
//                     Icon(Icons.bookmark_add_outlined, color: AppColors.accent),
//                 label: Text(
//                   'حفظ',
//                   style: GoogleFonts.cairo(
//                       color: AppColors.primary, fontWeight: FontWeight.w600),
//                 ),
//               ),
//           ],
//         ),
//         body: CustomScrollView(
//           slivers: [
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             AppColors.success.withOpacity(0.1),
//                             AppColors.accent.withOpacity(0.06),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(18),
//                         border: Border.all(
//                             color: AppColors.success.withOpacity(0.25)),
//                       ),
//                       child: Row(
//                         children: [
//                           Text(widget.meal.imageEmoji,
//                               style: TextStyle(fontSize: 48)),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.success.withOpacity(0.15),
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Text(
//                                     '✓ وجبة مقبولة',
//                                     style: GoogleFonts.cairo(
//                                       fontSize: 11,
//                                       color: AppColors.success,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 6),
//                                 Text(
//                                   widget.meal.name,
//                                   style: GoogleFonts.cairo(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w800,
//                                     color: AppColors.textPrimary,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.timer_outlined,
//                                         size: 12,
//                                         color: AppColors.textSecondary),
//                                     SizedBox(width: 4),
//                                     Text(
//                                       '${widget.meal.cookingTimeMinutes} دقيقة',
//                                       style: GoogleFonts.cairo(
//                                           fontSize: 12,
//                                           color: AppColors.textSecondary),
//                                     ),
//                                     SizedBox(width: 12),
//                                     Icon(Icons.group_outlined,
//                                         size: 12,
//                                         color: AppColors.textSecondary),
//                                     SizedBox(width: 4),
//                                     Text(
//                                       '${widget.meal.servings} أشخاص',
//                                       style: GoogleFonts.cairo(
//                                           fontSize: 12,
//                                           color: AppColors.textSecondary),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 24),
//                     if (!hasItems) ...[
//                       EmptyState(
//                         icon: Icons.check_circle_outline_rounded,
//                         title: 'جميع المقادير متوفرة!',
//                         subtitle:
//                             'لديك كل ما تحتاجه لتحضير هذه الوجبة اللذيذة.',
//                       ),
//                     ] else ...[
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'المقادير المطلوبة',
//                                   style:
//                                       Theme.of(context).textTheme.headlineSmall,
//                                 ),
//                                 SizedBox(height: 2),
//                                 Text(
//                                   '${_checkedItems.length} من ${widget.shoppingList.length} تم شراؤها',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall
//                                       ?.copyWith(color: AppColors.primary),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (allChecked)
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: AppColors.success.withOpacity(0.12),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.check_circle_rounded,
//                                       color: AppColors.success, size: 16),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     'اكتملت القائمة!',
//                                     style: GoogleFonts.cairo(
//                                       fontSize: 12,
//                                       color: AppColors.success,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(4),
//                         child: LinearProgressIndicator(
//                           value: hasItems
//                               ? _checkedItems.length /
//                                   widget.shoppingList.length
//                               : 0,
//                           backgroundColor: AppColors.divider,
//                           color: AppColors.success,
//                           minHeight: 6,
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//             if (hasItems)
//               SliverPadding(
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       final item = widget.shoppingList[index];
//                       final isChecked = _checkedItems.contains(item);
//                       return Padding(
//                         padding: EdgeInsets.only(bottom: 10),
//                         child: _ShoppingItem(
//                           item: item,
//                           isChecked: isChecked,
//                           onToggle: () {
//                             setState(() {
//                               if (isChecked) {
//                                 _checkedItems.remove(item);
//                               } else {
//                                 _checkedItems.add(item);
//                               }
//                             });
//                           },
//                         ),
//                       );
//                     },
//                     childCount: widget.shoppingList.length,
//                   ),
//                 ),
//               ),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     SizedBox(height: 8),
//                     _DetailSection(
//                       title: 'المقادير المتوفرة لديك',
//                       icon: Icons.kitchen_rounded,
//                       color: AppColors.accent,
//                       child: Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: widget.meal.ingredients
//                             .where((i) =>
//                                 !widget.meal.missingIngredients.contains(i))
//                             .map((ing) => Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.accent.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(20),
//                                     border: Border.all(
//                                         color:
//                                             AppColors.accent.withOpacity(0.3)),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(Icons.check_rounded,
//                                           size: 12, color: AppColors.accent),
//                                       SizedBox(width: 4),
//                                       Text(
//                                         ing,
//                                         style: GoogleFonts.cairo(
//                                           fontSize: 12,
//                                           color: AppColors.accent,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                     ),
//                     SizedBox(height: 32),
//                     SizedBox(height: 32),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ShoppingItem extends StatelessWidget {
//   final String item;
//   final bool isChecked;
//   final VoidCallback onToggle;

//   const _ShoppingItem({
//     required this.item,
//     required this.isChecked,
//     required this.onToggle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 200),
//       decoration: BoxDecoration(
//         color:
//             isChecked ? AppColors.success.withOpacity(0.06) : AppColors.cardBg,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: isChecked
//               ? AppColors.success.withOpacity(0.3)
//               : AppColors.divider,
//         ),
//       ),
//       child: ListTile(
//         onTap: onToggle,
//         leading: AnimatedContainer(
//           duration: Duration(milliseconds: 200),
//           width: 26,
//           height: 26,
//           decoration: BoxDecoration(
//             color: isChecked ? AppColors.success : Colors.transparent,
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: isChecked ? AppColors.success : AppColors.divider,
//               width: 2,
//             ),
//           ),
//           child: isChecked
//               ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
//               : null,
//         ),
//         title: Text(
//           item,
//           style: GoogleFonts.cairo(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: isChecked ? AppColors.textHint : AppColors.textPrimary,
//             decoration: isChecked ? TextDecoration.lineThrough : null,
//           ),
//         ),
//         trailing: Icon(
//           Icons.shopping_cart_outlined,
//           size: 18,
//           color: isChecked ? AppColors.success : AppColors.warning,
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       ),
//     );
//   }
// }

// class _DetailSection extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color color;
//   final Widget child;

//   const _DetailSection({
//     required this.title,
//     required this.icon,
//     required this.color,
//     required this.child,
//   });

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
//               Icon(icon, size: 18, color: color),
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
