// import 'package:cloud_firestore/cloud_firestore.dart';

// class Category {

//   final String name;
//   final List<String> subcategories;

//   Category({required this.name, required this.subcategories});

//   factory Category.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map;
//     return Category(
//       name: data['name'] ?? '',
//       subcategories: List<String>.from(data['subcategories'] ?? []),
//     );
//   }
// // }
