import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_item.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/product_detail_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isLoading = true;
  List<ProductItem> _activeProducts = [];
  List<ProductItem> _inactiveProducts = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch user products from Firestore
  Future<void> _fetchUserProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collection('products')
              .where('userID', isEqualTo: _userId)
              .get();

      final List<ProductItem> allProducts =
          querySnapshot.docs.map((doc) {
            return ProductItem.fromFirestore(doc);
          }).toList();

      setState(() {
        _activeProducts =
            allProducts.where((product) => product.visible).toList();
        _inactiveProducts =
            allProducts.where((product) => !product.visible).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger vos annonces')),
      );
    }
  }

  // Toggle product visibility
  Future<void> _toggleProductVisibility(ProductItem product) async {
    try {
      await _firestore.collection('products').doc(product.id).update({
        'visible': !product.visible,
      });

      // Refresh product list
      _fetchUserProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product.visible
                ? 'Annonce désactivée avec succès'
                : 'Annonce activée avec succès',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error toggling product visibility: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Une erreur est survenue')));
    }
  }

  // Delete product
  Future<void> _deleteProduct(ProductItem product) async {
    try {
      await _firestore.collection('products').doc(product.id).delete();

      // Refresh product list
      _fetchUserProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Annonce supprimée avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de supprimer l\'annonce')),
      );
    }
  }

  // Navigate to edit product screen
  void _navigateToEditScreen(ProductItem product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    ).then((_) => _fetchUserProducts()); // Refresh products after editing
  }

  // Show confirmation dialog for delete
  void _showDeleteConfirmationDialog(ProductItem product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer l\'annonce'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette annonce?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(product);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ma publicité'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Actives'), Tab(text: 'Inactives')],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  controller: _tabController,
                  children: [
                    // Active products tab
                    _buildProductList(_activeProducts, true),

                    // Inactive products tab
                    _buildProductList(_inactiveProducts, false),
                  ],
                ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF008080),
          onPressed: () {
            // Navigate to StepOne to create a new ad
            Navigator.pushNamed(
              context,
              '/create-ad',
            ).then((_) => _fetchUserProducts());
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductList(List<ProductItem> products, bool isActive) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              isActive
                  ? 'Vous n\'avez pas d\'annonces actives'
                  : 'Vous n\'avez pas d\'annonces inactives',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 24),
            if (!isActive)
              ElevatedButton(
                onPressed: () => _tabController.animateTo(0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080),
                ),
                child: Text(
                  'Voir les annonces actives',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUserProducts,
      child: ListView.builder(
        padding: EdgeInsets.all(12.r),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(color: Colors.grey[200]),
                        child:
                            product.imagesUrl.isNotEmpty
                                ? Image.network(
                                  product.imagesUrl[0],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                                : Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            product.getFormattedPrice(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            product.categoryName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Product stats and features
                          Row(
                            children: [
                              if (product.isAdvertising)
                                _buildFeatureChip('Sponsorisée', Colors.blue),
                              if (product.isBestSeller)
                                _buildFeatureChip('Best Seller', Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Column(
                      children: [
                        // Edit button
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.grey[600]),
                          onPressed: () => _navigateToEditScreen(product),
                        ),

                        // Toggle visibility button
                        IconButton(
                          icon: Icon(
                            isActive ? Icons.visibility_off : Icons.visibility,
                            color: isActive ? Colors.red : Colors.green,
                          ),
                          onPressed: () => _toggleProductVisibility(product),
                        ),

                        // Delete button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              () => _showDeleteConfirmationDialog(product),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class EditProductScreen extends StatefulWidget {
  final ProductItem product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  List<String> _existingImageUrls = [];
  List<XFile> _newImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _priceController = TextEditingController(text: widget.product.price);
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _existingImageUrls = List.from(widget.product.imagesUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (selectedImage != null) {
        setState(() {
          _newImages.add(selectedImage);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image')),
      );
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez inclure au moins une image')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Upload any new images
        List<String> allImageUrls = List.from(_existingImageUrls);

        for (int i = 0; i < _newImages.length; i++) {
          XFile image = _newImages[i];
          String imagePath =
              'products/${widget.product.id}/image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          Reference storageRef = _storage.ref().child(imagePath);

          File imageFile = File(image.path);
          await storageRef.putFile(imageFile);

          String downloadUrl = await storageRef.getDownloadURL();
          allImageUrls.add(downloadUrl);
        }

        // Update Firestore document
        await _firestore.collection('products').doc(widget.product.id).update({
          'title': _titleController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'imagesUrl': allImageUrls,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Annonce mise à jour avec succès')),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error updating product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour de l\'annonce'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier l\'annonce')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Images section
                      Text(
                        'Images',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Image gallery
                      _buildImageGallery(),
                      SizedBox(height: 24.h),

                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Titre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir un titre';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Price field
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Prix (DZD)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monetization_on),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir un prix';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir une description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Product info (non-editable)
                      _buildInfoSection(),
                      SizedBox(height: 32.h),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _updateProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008080),
                          ),
                          child: Text(
                            'Mettre à jour l\'annonce',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildImageGallery() {
    // Calculate total image count (existing + new)
    int totalImages = _existingImageUrls.length + _newImages.length;
    int maxImages = 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image count indicator
        Text(
          'Images ($totalImages/$maxImages)',
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(height: 8.h),

        // Image grid
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount:
              _existingImageUrls.length +
              _newImages.length +
              (totalImages < maxImages ? 1 : 0),
          itemBuilder: (context, index) {
            // Add image button
            if (index == totalImages && totalImages < maxImages) {
              return _buildAddImageButton();
            }

            // Existing images
            if (index < _existingImageUrls.length) {
              return _buildExistingImageTile(index);
            }

            // New images
            return _buildNewImageTile(index - _existingImageUrls.length);
          },
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Icon(Icons.add_photo_alternate, color: Colors.grey, size: 40),
        ),
      ),
    );
  }

  Widget _buildExistingImageTile(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
            image: DecorationImage(
              image: NetworkImage(_existingImageUrls[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removeExistingImage(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImageTile(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(
              File(_newImages[index].path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removeNewImage(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations supplémentaires',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),

        // Category & Subcategory
        _buildInfoRow('Catégorie', widget.product.categoryName),
        _buildInfoRow('Sous-catégorie', widget.product.subcategory),

        // Date posted
        _buildInfoRow(
          'Date de publication',
          DateFormat('dd/MM/yyyy').format(widget.product.createdAt),
        ),

        // Special features
        if (widget.product.isAdvertising)
          _buildInfoRow('Publicité', 'Active', true),

        if (widget.product.isBestSeller)
          _buildInfoRow('Best Seller', 'Oui', true),

        // Visibility status
        _buildInfoRow(
          'Statut',
          widget.product.visible ? 'Visible' : 'Non visible',
          true,
          widget.product.visible ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, [
    bool withIcon = false,
    Color? iconColor,
  ]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          if (withIcon)
            Icon(Icons.circle, size: 10, color: iconColor ?? Colors.blue),
          SizedBox(width: 4.w),
          Text(value),
        ],
      ),
    );
  }
}
