// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryItem {
  final String id;
  final String name;
  final String imageUrl;
  final int count;
  final List<String> subcategories;

  CategoryItem({
    required this.name,
    required this.imageUrl,
    required this.count,
    required this.id,
    required this.subcategories,
  });

  factory CategoryItem.fromFirestore(DocumentSnapshot doc) {
    return CategoryItem(
      id: doc.id,
      name: doc['name'],
      imageUrl: doc['imageUrl'],
      count: doc['count'],
      subcategories: List<String>.from(doc['subcategories'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'imageUrl': imageUrl,
      'count': count,
    };
  }
}
