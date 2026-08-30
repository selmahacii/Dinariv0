// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/ads_item.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_card.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_item.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_card_widget.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_item.dart';
import 'package:dinari/src/presentation/widgets/scrollbar_card_widget.dart';
import 'package:dinari/src/presentation/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  bool isDataLoaded = false;
  List<ProductItem> products = [];
  List<CategoryItem> categories = [];
  List<AdsItem> ads = [];
  List<ProductItem> filteredProducts = []; // New list for filtered products
  String searchQuery = ''; // Track current search query

  Future<List<AdsItem>> _loadAds() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('advertisements').get();
    final ads =
        querySnapshot.docs.map((doc) => AdsItem.fromFirestore(doc)).toList();
    print('=> Ads: $ads');
    return ads;
  }

  Future<List<ProductItem>> _loadProducts() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    final products =
        querySnapshot.docs
            .map((doc) => ProductItem.fromFirestore(doc))
            .toList();
    print('=> Products: $products');
    return products;
  }

  Future<List<CategoryItem>> _loadCategories() async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('categories')
            // .limit(8)
            .get();
    categories =
        querySnapshot.docs
            .map((doc) => CategoryItem.fromFirestore(doc))
            .toList();
    print('=> Categories: ${categories.length}');
    return categories;
  }

  Future<void> _fetchData() async {
    try {
      ads = await _loadAds();
      products = await _loadProducts();
      filteredProducts = List.from(products); // Initialize filtered list
      categories = await _loadCategories();
    } catch (e) {
      print('=> Error fetching data: $e');
    } finally {
      setState(() {
        isDataLoaded = true;
      });
    }
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        // If search is cleared, show all products
        filteredProducts = List.from(products);
      } else {
        // Filter products based on search query
        filteredProducts =
            products.where((product) {
              final name = product.title.toLowerCase();
              final description = product.description?.toLowerCase() ?? '';
              final searchLower = query.toLowerCase();

              return name.contains(searchLower) ||
                  description.contains(searchLower);
            }).toList();
      }
    });

    // You could also implement Firestore query search here instead of client-side filtering
    // if you have a large dataset
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isDataLoaded
        ? SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                8.verticalSpace,
                SearchField(
                  onSearch: _handleSearch,
                  hintText: 'Trouve ce que tu veux',
                ),
                8.verticalSpace,
                // Show search results if there's a search query
                if (searchQuery.isNotEmpty) _buildSearchResults(),
                // Only show these sections if not searching
                if (searchQuery.isEmpty) ...[
                  ScrollbarCardWidget(adsItems: ads),
                  8.verticalSpace,
                  SizedBox(
                    width: double.infinity,
                    height: 250,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                          ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCard(category: categories[index]);
                      },
                    ),
                  ),
                  _buildSection(
                    title: 'publicité',
                    viewAllText: 'Voir tout',
                    isAdvertising: true,
                    isBestSeller: false,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Meilleures ventes',
                    viewAllText: 'Voir tout',
                    isAdvertising: false,
                    isBestSeller: true,
                  ),
                  const SizedBox(height: 24),
                  ...categories.map((category) {
                    // if(category)
                    return Column(
                      children: [
                        _buildSection(
                          title: category.name,
                          viewAllText: 'Voir tout',
                          isAdvertising: false,
                          isBestSeller: false,
                          category: category.name,
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),
                ],
              ],
            ),
          ),
        )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildSection({
    required String title,
    required String viewAllText,
    required bool isAdvertising,
    required bool isBestSeller,
    String? category,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildProductStream(
        isAdvertising: isAdvertising,
        isBestSeller: isBestSeller,
        category: category,
      ),
      builder: (context, snapshot) {
        // If no data or empty docs, return null to not render the widget
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement navigation to see all products
                    },
                    child: Text(
                      viewAllText,
                      style: const TextStyle(
                        color: Color(0xFF008080),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              // Products Grid
              SizedBox(
                height: 230.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = ProductItem.fromFirestore(doc);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ProductCardWidget(data: data),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build the Firestore query stream
  Stream<QuerySnapshot> _buildProductStream({
    required bool isAdvertising,
    required bool isBestSeller,
    String? category,
  }) {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('visible', isEqualTo: true);

    // Add category filter if provided
    if (category != null) {
      query = query.where('categoryName', isEqualTo: category);
    } else {
      // If no category, apply advertising or best seller filter
      query = query.where(
        isAdvertising ? 'isAdvertising' : 'isBestSeller',
        isEqualTo: true,
      );
    }

    return query.limit(6).snapshots();
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Résultats pour "$searchQuery"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${filteredProducts.length} produits',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          filteredProducts.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Aucun produit trouvé',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
              : GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCardWidget(data: filteredProducts[index]);
                },
              ),
        ],
      ),
    );
  }
}
