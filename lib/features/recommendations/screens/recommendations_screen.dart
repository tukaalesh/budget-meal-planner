// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sho_htghadona/features/recommendations/models/meal_model.dart';
// import '../bloc/recommendations_bloc.dart';
// import '../../meal_request/bloc/meal_request_bloc.dart';
// import '../widgets/meal_card.dart';
// import '../screens/meal_detail_screen.dart';
// import '../screens/shopping_list_screen.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/widgets/app_widgets.dart';

// class RecommendationsScreen extends StatelessWidget {
//   const RecommendationsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => RecommendationsBloc(),
//       child: Directionality(
//         textDirection: TextDirection.rtl,
//         child: BlocConsumer<RecommendationsBloc, RecommendationsState>(
//           listener: (context, state) {
//             // if (state is MealAcceptedState) {
//             //   Navigator.of(context).push(MaterialPageRoute(
//             //     builder: (_) => ShoppingListScreen(
//             //       meal: state.meal,
//             //       shoppingList: state.shoppingList,
//             //     ),
//             //   ));
//             // }
//           },
//           builder: (context, recState) {
//             return BlocBuilder<MealRequestBloc, MealRequestState>(
//               builder: (context, reqState) {
//                 if (reqState is! MealRequestSuccess) {
//                   return Scaffold(
//                     body: Center(
//                         child:
//                             Text('لا توجد توصيات', style: GoogleFonts.cairo())),
//                   );
//                 }

//                 final meals = reqState.recommendations;
//                 final request = reqState.request;

//                 return Scaffold(
//                   backgroundColor: AppColors.background,
//                   body: CustomScrollView(
//                     slivers: [
//                       SliverAppBar(
//                         pinned: true,
//                         expandedHeight: 160,
//                         backgroundColor: AppColors.surface,
//                         flexibleSpace: FlexibleSpaceBar(
//                           titlePadding:
//                               EdgeInsets.only(right: 16, left: 60, bottom: 16),
//                           title: Text(
//                             'التوصيات المقترحة',
//                             style: GoogleFonts.cairo(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                               color: AppColors.textPrimary,
//                             ),
//                           ),
//                           background: Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   AppColors.primary.withOpacity(0.11),
//                                   AppColors.primaryLight.withOpacity(0.06),
//                                   AppColors.background,
//                                 ],
//                                 begin: Alignment.topRight,
//                                 end: Alignment.bottomLeft,
//                               ),
//                             ),
//                             child: Padding(
//                               padding:
//                                   EdgeInsets.only(top: 56, right: 20, left: 20),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       // Icon(Icons.auto_awesome_rounded,
//                                       //     color: AppColors.secondary, size: 18),
//                                       // SizedBox(width: 6),
//                                       Text(
//                                         'وجدنا ${meals.length} وجبة مناسبة لك',
//                                         style: GoogleFonts.cairo(
//                                           fontSize: 13,
//                                           color: AppColors.textSecondary,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 8),
//                                   Row(
//                                     children: [
//                                       _SummaryPill(
//                                           icon: Icons.attach_money_rounded,
//                                           label:
//                                               '${request.budget.round()} ل.س',
//                                           color: AppColors.success),
//                                       SizedBox(width: 8),
//                                       _SummaryPill(
//                                           icon: Icons.timer_outlined,
//                                           label: request.cookingTimeLevel.label,
//                                           color: AppColors.secondary),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         actions: [
//                           IconButton(
//                             icon: Icon(Icons.refresh_rounded,
//                                 color: AppColors.accent),
//                             onPressed: recState is RecommendationsRefreshing
//                                 ? null
//                                 : () {
//                                     context.read<RecommendationsBloc>().add(
//                                         NewRecommendationsRequested(request));
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                             'جاري توليد توصيات جديدة...',
//                                             style: GoogleFonts.cairo()),
//                                         backgroundColor: AppColors.accent,
//                                         duration: Duration(seconds: 2),
//                                       ),
//                                     );
//                                     Navigator.of(context).pop();
//                                   },
//                             tooltip: 'توصيات جديدة',
//                           ),
//                         ],
//                       ),
//                       if (recState is RecommendationsRefreshing)
//                         SliverFillRemaining(
//                           child: LoadingOverlay(
//                               message: 'جاري توليد توصيات جديدة...'),
//                         )
//                       else
//                         SliverPadding(
//                           padding: EdgeInsets.all(20),
//                           sliver: SliverList(
//                             delegate: SliverChildBuilderDelegate(
//                               (context, index) {
//                                 if (index == meals.length) {
//                                   return Padding(
//                                     padding:
//                                         EdgeInsets.only(top: 8, bottom: 32),
//                                     child: OutlinedButton.icon(
//                                       onPressed: () {
//                                         context.read<RecommendationsBloc>().add(
//                                             NewRecommendationsRequested(
//                                                 request));
//                                         Navigator.of(context).pop();
//                                       },
//                                       icon: Icon(Icons.refresh_rounded),
//                                       label: Text(
//                                         'طلب توصيات جديدة',
//                                         style: GoogleFonts.cairo(
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                     ),
//                                   );
//                                 }
//                                 final meal = meals[index];
//                                 return Padding(
//                                   padding: EdgeInsets.only(bottom: 16),
//                                   child: MealCard(
//                                     meal: meal,
//                                     onAccept: () {
//                                       context
//                                           .read<RecommendationsBloc>()
//                                           .add(MealAccepted(meal));
//                                     },
//                                     onViewDetails: () {
//                                       Navigator.of(context)
//                                           .push(MaterialPageRoute(
//                                         builder: (_) =>
//                                             MealDetailScreen(meal: meal),
//                                       ));
//                                     },
//                                   ),
//                                 );
//                               },
//                               childCount: meals.length + 1,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class _SummaryPill extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;

//   const _SummaryPill(
//       {required this.icon, required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.25)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: color),
//           SizedBox(width: 4),
//           Text(
//             label,
//             style: GoogleFonts.cairo(
//                 fontSize: 11, color: color, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
// }
