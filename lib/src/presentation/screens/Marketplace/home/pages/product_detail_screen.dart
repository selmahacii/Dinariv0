// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/chat_list_screen.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_card_widget.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final ProductItem product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _startOrNavigateToChat() async {
    try {
      // Check if a chat already exists with this seller
      String? existingChatId = await _findExistingChat();
      String otherUserName = await _getOtherUserName(widget.product.userID);
      print('=> existingChatId: $existingChatId');
      print('=> otherUserName: $otherUserName');

      if (existingChatId != null) {
        // Navigate to existing chat
        _navigateToChatScreen(existingChatId, otherUserName);
      } else {
        // Create a new chat
        String newChatId = await _createNewChat();
        print('=> newChatId: $newChatId');
        _navigateToChatScreen(newChatId, otherUserName);
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start chat: ${e.toString()}')),
      );
    }
  }

  Future<String> _getOtherUserName(String userId) async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userSnapshot = await userCollection.doc(userId).get();
    return userSnapshot.data()?['fullName'] ?? 'Unknown User';
  }

  Future<String?> _findExistingChat() async {
    // Query Firestore to find an existing chat
    final chatsCollection = FirebaseFirestore.instance.collection('chats');

    // Query for a chat between current user and seller
    final querySnapshot =
        await chatsCollection
            .where('participants', arrayContainsAny: [getCurrentUserId()])
            // .limit(1)
            .get();

    var docs = querySnapshot.docs;
    docs.removeWhere(
      (element) =>
          !element.data()['participants'].contains(widget.product.userID),
    );

    print('=> querySnapshot: $docs');

    // Return chat ID if exists, otherwise null
    return docs.isEmpty ? null : docs.first.id;
    // return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.id : null;
  }

  Future<String> _createNewChat() async {
    // Create a new chat document in Firestore
    final chatsCollection = FirebaseFirestore.instance.collection('chats');

    // final newChatRef = chatsCollection.doc();

    final newChatRef = await chatsCollection.add({
      'participants': [getCurrentUserId(), widget.product.userID],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
      'lastMessageTime': null,
      'lastMessageSenderId': null,
      'seen': false,
    });

    return newChatRef.id;
  }

  void _navigateToChatScreen(String chatId, String otherUserName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              chatId: chatId,
              otherUserId: widget.product.userID,
              otherUserName: otherUserName,
            ),
      ),
    );
  }

  // Ensure you have a method to get the current user's ID
  String getCurrentUserId() {
    // Implement this based on your authentication system
    // For example, using Firebase Authentication
    return FirebaseAuth.instance.currentUser!.uid;
  }

  // Update the Chat button in _buildProductDetails method

  // Add these helper methods to the class:

  Widget _buildContactButton({
    required IconData icon,
    required Color color,
    Color? iconColor,
    Color? borderColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border:
                  borderColor != null
                      ? Border.all(color: borderColor, width: 1)
                      : null,
            ),
            child: Icon(icon, color: iconColor ?? Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  void _launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch phone dialer')));
    }
  }

  /// Récupère le numéro de téléphone du vendeur puis l'affiche dans une
  /// boîte de dialogue (avec possibilité d'appeler directement).
  Future<void> _showSellerPhone() async {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    String? phone;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.product.userID)
          .get();
      final data = doc.data();
      final raw = (data?['phoneNumber'] ?? data?['phone'] ?? '').toString().trim();
      if (raw.isNotEmpty) phone = raw;
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pop(); // ferme le loader

    if (phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro du vendeur indisponible')),
      );
      return;
    }

    final number = phone;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Numéro du vendeur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, color: Color(0xFF008080), size: 40),
            const SizedBox(height: 12),
            SelectableText(
              number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008080),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _launchPhone(number);
            },
            icon: const Icon(Icons.call, size: 18),
            label: const Text('Appeler'),
          ),
        ],
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Regarding: ${widget.product.title}'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch email app')));
    }
  }

  void _launchWhatsApp(String phoneNumber) async {
    final message =
        'Hello, I am interested in your product: ${widget.product.title}';
    final Uri uri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share product
              Share.share(
                'Check out this product: ${widget.product.title} - ${widget.product.getFormattedPrice()}',
              );
            },
          ),
        ],
      ),
      body: _buildProductDetails(),
    );
  }

  Widget _buildProductDetails() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image carousel
          _buildImageCarousel(),

          // Title and price section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Phone button
                    _buildContactButton(
                      icon: Icons.phone,
                      color: const Color(0xFF008080),
                      label: 'Call',
                      onTap: _showSellerPhone,
                    ),

                    // Email button
                    _buildContactButton(
                      icon: Icons.email,
                      color: Colors.white,
                      iconColor: const Color(0xFF008080),
                      borderColor: const Color(0xFF008080),
                      label: 'Email',
                      onTap: () {
                        _launchEmail(
                          'seller@example.com',
                        ); // Replace with actual email
                      },
                    ),

                    // Chat button
                    _buildContactButton(
                      icon: Icons.chat_bubble_outline,
                      color: Colors.white,
                      iconColor: const Color(0xFF008080),
                      borderColor: const Color(0xFF008080),
                      label: 'Chat',
                      onTap: () {
                        _startOrNavigateToChat();
                      },
                    ),

                    // WhatsApp button
                    _buildContactButton(
                      icon: Icons.phone, // Or use a custom WhatsApp icon
                      color: const Color(0xFF25D366), // WhatsApp green
                      label: 'WhatsApp',
                      onTap: () {
                        // _launchWhatsApp(
                        //   '+1234567890',
                        // ); // Replace with actual phone number
                      },
                    ),
                  ],
                ),
                12.verticalSpace,
                // Category
                Text(
                  widget.product.categoryName.toLowerCase(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),

                // Title
                Text(
                  widget.product.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),

                // Price
                Text(
                  widget.product.getFormattedPrice(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 8),

                // Rating
                Row(
                  children: [
                    _buildRatingStars(widget.product.rating),
                    SizedBox(width: 8),
                    Text(
                      '(${widget.product.rating.toStringAsFixed(1)})',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),

                _buildDivider(),

                // Description section header
                Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // Description content
                Text(
                  widget.product.description,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),

                _buildDivider(),

                // Additional information
                _buildAdditionalInfo(),

                // Similar products could be added here
                // _buildSimilarProducts(),
              ],
            ),
          ),
          8.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final List<String> images = widget.product.imagesUrl;

    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildImageItem(images[index]);
            },
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(height: 10),
          _buildImageIndicators(images.length),
        ],
      ],
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Show image in full screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _FullScreenImage(imageUrl: imageUrl),
          ),
        );
      },
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 50),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _currentImageIndex == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 20, color: Colors.amber);
        } else if (index == rating.floor() && rating % 1 > 0) {
          return const Icon(Icons.star_half, size: 20, color: Colors.amber);
        } else {
          return const Icon(Icons.star_border, size: 20, color: Colors.amber);
        }
      }),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(height: 1, thickness: 1),
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        _buildInfoItem('Category', widget.product.categoryName),
        _buildInfoItem('Subcategory', widget.product.subcategory),
        _buildInfoItem(
          'Listed on',
          DateFormat('MMM dd, yyyy').format(widget.product.createdAt),
        ),
        if (widget.product.isBestSeller)
          _buildInfoItem('Status', 'Best Seller', Icons.verified, Colors.green),
      ],
    );
  }

  Widget _buildInfoItem(
    String label,
    String value, [
    IconData? icon,
    Color? iconColor,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          if (icon != null) ...[
            Icon(icon, size: 16, color: iconColor),
            SizedBox(width: 4),
          ],
          Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[900])),
        ],
      ),
    );
  }
}

// Full screen image viewer
class _FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
