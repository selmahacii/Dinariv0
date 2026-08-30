import 'package:cloud_firestore/cloud_firestore.dart';

class ProductItem {
  final String id;
  final String title;
  final String price;
  final double rating;
  final List<String> imagesUrl;
  final String description;
  final String category;
  final String categoryName;
  final String categoryImageUrl;
  final String subcategory;
  final String userID;
  final bool visible;
  final bool isAdvertising;
  final bool isBestSeller;
  final DateTime createdAt;

  ProductItem({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.imagesUrl,
    required this.description,
    required this.category,
    required this.categoryName,
    required this.categoryImageUrl,
    required this.subcategory,
    required this.userID,
    required this.visible,
    required this.isAdvertising,
    required this.isBestSeller,
    required this.createdAt,
  });

  // Create a Product from a Firestore document
  factory ProductItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ProductItem(
      id: doc.id,
      title: data['title'] ?? '',
      price: data['price'] ?? '0',
      rating: (data['rating'] ?? 0.0).toDouble(),
      imagesUrl: List<String>.from(data['imagesUrl'] ?? []),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      categoryName: data['categoryName'] ?? '',
      categoryImageUrl: data['categoryImageUrl'] ?? '',
      subcategory: data['subcategory'] ?? '',
      userID: data['userID'] ?? '',
      visible: data['visible'] ?? true,
      isAdvertising: data['isAdvertising'] ?? false,
      isBestSeller: data['isBestSeller'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert the Product to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'price': price,
      'rating': rating,
      'imagesUrl': imagesUrl,
      'description': description,
      'category': category,
      'categoryName': categoryName,
      'categoryImageUrl': categoryImageUrl,
      'subcategory': subcategory,
      'userID': userID,
      'visible': visible,
      'isAdvertising': isAdvertising,
      'isBestSeller': isBestSeller,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Helper methods
  double getPriceAsDouble() {
    try {
      return double.parse(price.replaceAll(',', '.'));
    } catch (e) {
      return 0.0;
    }
  }

  String getFormattedPrice() {
    return '$price DZD';
  }

  String getMainImage() {
    return imagesUrl.isNotEmpty ? imagesUrl[0] : '';
  }

  // Create a copy of the product with some fields updated
  ProductItem copyWith({
    String? title,
    String? price,
    double? rating,
    List<String>? imagesUrl,
    String? description,
    String? category,
    String? categoryName,
    String? categoryImageUrl,
    String? subcategory,
    String? userID,
    bool? visible,
    bool? isAdvertising,
    bool? isBestSeller,
    DateTime? createdAt,
  }) {
    return ProductItem(
      id: this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      imagesUrl: imagesUrl ?? this.imagesUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      categoryImageUrl: categoryImageUrl ?? this.categoryImageUrl,
      subcategory: subcategory ?? this.subcategory,
      userID: userID ?? this.userID,
      visible: visible ?? this.visible,
      isAdvertising: isAdvertising ?? this.isAdvertising,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, title: $title, price: $price, category: $categoryName, subcategory: $subcategory}';
  }
}