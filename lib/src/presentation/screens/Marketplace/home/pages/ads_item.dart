// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class AdsItem {
  final String id;
  final String imageUrl;

  AdsItem({required this.id, required this.imageUrl});

  factory AdsItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdsItem(id: doc.id, imageUrl: data['imageUrl']);
  }
}
