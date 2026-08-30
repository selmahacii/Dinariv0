// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_card.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_item.dart';
import 'package:dinari/src/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';

class CategoriesGrid extends StatelessWidget {
  final List<CategoryItem> categories;
  final int crossAxisCount;

  const CategoriesGrid({
    super.key,
    required this.categories,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryCard(category: categories[index]);
      },
    );
  }
}
