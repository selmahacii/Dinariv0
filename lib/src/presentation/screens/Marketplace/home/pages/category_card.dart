// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_item.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_products_screen.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryProductsScreen(category: category),)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(category.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ),
          const SizedBox(height: 8),
          // Category name
          Text(
            category.name,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Product count
          Text(
            "${category.count} p",
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
