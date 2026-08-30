import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_item.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_card_widget.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_item.dart';
import 'package:flutter/material.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key, required this.category});
  final CategoryItem category;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  bool _isLoading = true;
  List<ProductItem> _products = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch products from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where('category', isEqualTo: widget.category.id)
              .where('visible', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      // Convert documents to ProductItem objects
      final products =
          snapshot.docs.map((doc) => ProductItem.fromFirestore(doc)).toList();

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadProducts, child: Text('Retry')),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No products found in this category',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadProducts, child: Text('Refresh')),
          ],
        ),
      );
    }

    // Display products in a grid
    return SingleChildScrollView(
      child: RefreshIndicator(
        onRefresh: _loadProducts,
        child: Padding(
          padding: EdgeInsets.only(left: 8),
          child: Column(
            children: [
              Center(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 16.0,
                  runSpacing: 16.0,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: List.generate(_products.length, (index) {
                    final product = _products[index];
                    return ProductCardWidget(data: product);
                  }),
                ),
              ),
            ],
          ),
          // child: GridView.builder(
          //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 2,
          //     childAspectRatio: 0.75,
          //     crossAxisSpacing: 10,
          //     mainAxisSpacing: 10,
          //   ),
          //   itemCount: _products.length,
          //   itemBuilder: (context, index) {
          //     final product = _products[index];
          //     return _buildProductCard(product);
          //   },
          // ),
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Price: Low to High
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text('Price: Low to High'),
                onTap: () {
                  Navigator.pop(context);
                  _sortProducts('price_asc');
                },
              ),

              // Price: High to Low
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text('Price: High to Low'),
                onTap: () {
                  Navigator.pop(context);
                  _sortProducts('price_desc');
                },
              ),

              // Rating: High to Low
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rating: High to Low'),
                onTap: () {
                  Navigator.pop(context);
                  _sortProducts('rating');
                },
              ),

              // Newest First
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Newest First'),
                onTap: () {
                  Navigator.pop(context);
                  _sortProducts('newest');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sortProducts(String sortBy) {
    setState(() {
      switch (sortBy) {
        case 'price_asc':
          _products.sort(
            (a, b) => a.getPriceAsDouble().compareTo(b.getPriceAsDouble()),
          );
          break;
        case 'price_desc':
          _products.sort(
            (a, b) => b.getPriceAsDouble().compareTo(a.getPriceAsDouble()),
          );
          break;
        case 'rating':
          _products.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'newest':
          _products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    });
  }
}
