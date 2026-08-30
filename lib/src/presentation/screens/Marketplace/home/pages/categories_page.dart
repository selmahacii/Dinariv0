import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_item.dart';
import 'package:dinari/src/presentation/widgets/categories_grid.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  Future<List<CategoryItem>> _loadData() async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('categories')
            // .limit(8)
            .get();
    final categories =
        querySnapshot.docs
            .map((doc) => CategoryItem.fromFirestore(doc))
            .toList();
    print('=> Categories: $categories');
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return CategoriesGrid(categories: snapshot.data!, crossAxisCount: 3);
        },
      ),
    );
  }
}
