// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/chat_list_screen.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_detail_screen.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductCardWidget extends StatelessWidget {
  const ProductCardWidget({super.key, required this.data});
  final ProductItem data;

  @override
  Widget build(BuildContext context) {
    final String title = data.title;
    final String category = data.categoryName;
    final String price = data.price;
    final double rating = (data.rating).toDouble();
    final List<String> imagesUrl = List<String>.from(data.imagesUrl);
    final String imageUrl =
        imagesUrl.isNotEmpty
            ? imagesUrl[0]
            : 'https://loremflickr.com/800/600/${Uri.encodeComponent(data.categoryName.isNotEmpty ? data.categoryName : 'marketplace,product')}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: data),
          ),
        );
      },
      child: Container(
        width: 0.4.sw,
        // height: 360.h,
        // margin: REdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 110.h,
              width: 0.4.sw,
              decoration: BoxDecoration(
                color: const Color(0xFF008080),
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            6.verticalSpace,
            Padding(
              padding: REdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    category.toLowerCase(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Price
                  Text(
                    '$price DZD',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Rating
                  Row(
                    children: [
                      Text(
                        '(${rating.toStringAsFixed(1)})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 4),
                      _buildRatingStars(rating),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 14, color: Colors.amber);
        } else if (index == rating.floor() && rating % 1 > 0) {
          return const Icon(Icons.star_half, size: 14, color: Colors.amber);
        } else {
          return const Icon(Icons.star_border, size: 14, color: Colors.amber);
        }
      }),
    );
  }
}
