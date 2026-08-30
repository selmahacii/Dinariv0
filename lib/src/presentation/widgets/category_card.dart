// // ignore_for_file: public_member_api_docs, sort_constructors_first

// import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_item.dart';
// import 'package:dinari/src/presentation/screens/Marketplace/home/pages/marketplace_home_page.dart';
// import 'package:flutter/material.dart';

// class CategoryCard extends StatelessWidget {
//   final CategoryItem category;

//   const CategoryCard({super.key, required this.category});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             image: DecorationImage(
//               image: NetworkImage(category.imageUrl),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           category.name,
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 12),
//         ),
//         Text(
//           '${category.count} P',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//       ],
//     );
//   }
// }
