import 'dart:io';
import 'package:dinari/src/core/utils/constants/algeria_cites.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/category.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/category_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:uuid/uuid.dart';
 
class StepOne extends StatefulWidget {
  const StepOne({super.key});

  @override
  createState() => _StepOneState();
}

class _StepOneState extends State<StepOne> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CategoryItem> _categories = [];
  CategoryItem? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedWilaya;
  String? _selectedCommune;

  static List<String> getWilayatList() {
    Set<String> uniqueWilayaCodes = {};
    List<String> uniqueList = [];
    for (var entry in algeriaCites) {
      String wilayaCode = entry["wilaya_code"];
      // Add to the list if wilaya_code is not already in the Set
      if (!uniqueWilayaCodes.contains(wilayaCode)) {
        uniqueWilayaCodes.add(wilayaCode);
        uniqueList.add(entry["wilaya_name_ascii"]);
      }
    }
    return uniqueList;
  }

  static List<String> getCommunes(String? wilaya) {
    if (wilaya == null) {
      return [];
    }
    return algeriaCites
        .where((element) => element['wilaya_name_ascii'] == wilaya)
        .map((e) => e['commune_name_ascii'] as String)
        .toList();
  }

  List<String> _wilayaList = [];
  List<String> _communeList = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _wilayaList = getWilayatList();
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('categories').get();

      setState(() {
        _categories =
            querySnapshot.docs
                .map((doc) => CategoryItem.fromFirestore(doc))
                .toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger les catégories')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Étape 1'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Category Dropdown (unchanged)
              DropdownButtonFormField<CategoryItem>(
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items:
                    _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                onChanged: (CategoryItem? newCategory) {
                  setState(() {
                    _selectedCategory = newCategory;
                    _selectedSubcategory = null; // Reset subcategory
                  });
                },
                validator:
                    (value) =>
                        value == null
                            ? 'Veuillez sélectionner une catégorie'
                            : null,
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Sous-catégorie',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSubcategory,
                items:
                    (_selectedCategory?.subcategories ?? [])
                        .map(
                          (subcategory) => DropdownMenuItem(
                            value: subcategory,
                            child: Text(subcategory),
                          ),
                        )
                        .toList(),
                onChanged: (String? newSubcategory) {
                  setState(() {
                    _selectedSubcategory = newSubcategory;
                  });
                },
                validator:
                    (value) =>
                        value == null
                            ? 'Veuillez sélectionner une sous-catégorie'
                            : null,
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Wilaya',
                  border: OutlineInputBorder(),
                ),
                value: _selectedWilaya,
                items:
                    _wilayaList
                        .map(
                          (wilaya) => DropdownMenuItem(
                            value: wilaya,
                            child: Text(wilaya),
                          ),
                        )
                        .toList(),
                onChanged: (String? newWilaya) {
                  setState(() {
                    _selectedWilaya = newWilaya;
                    _communeList = getCommunes(newWilaya);
                    _selectedCommune = null; // Reset commune
                  });
                },
                validator:
                    (value) =>
                        value == null
                            ? 'Veuillez sélectionner une wilaya'
                            : null,
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Commune',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCommune,
                items:
                    _communeList
                        .map(
                          (commune) => DropdownMenuItem(
                            value: commune,
                            child: Text(commune),
                          ),
                        )
                        .toList(),
                onChanged: (String? newCommune) {
                  setState(() {
                    _selectedCommune = newCommune;
                  });
                },
                validator:
                    (value) =>
                        value == null
                            ? 'Veuillez sélectionner une commune'
                            : null,
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _validateAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Suivant',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => StepTwo(
                category: _selectedCategory,
                subcategory: _selectedSubcategory,
                wilaya: _selectedWilaya,
                commune: _selectedCommune,
              ),
        ),
      );
    }
  }
}

class StepTwo extends StatefulWidget {
  final CategoryItem? category;
  final String? subcategory;
  final String? wilaya;
  final String? commune;

  const StepTwo({
    super.key,
    this.category,
    this.subcategory,
    this.wilaya,
    this.commune,
  });

  @override
  _StepTwoState createState() => _StepTwoState();
}



class _StepTwoState extends State<StepTwo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final int _maxImages = 5;
  bool _isUploading = false;

  List<XFile> _selectedImages = [];
  
  // Check and request permissions for image picking
  Future<bool> _handlePermissions() async {
    // For Android API level >= 33, we need to request photo library access
    if (Platform.isAndroid) {
      var status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
      
      if (status.isPermanentlyDenied) {
        // Show a dialog directing the user to app settings
        _showPermissionSettingsDialog();
        return false;
      }
      
      return status.isGranted;
    }
    
    // For iOS, permission handling is managed by the image_picker itself
    return true;
  }
  
  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Permission requise'),
        content: Text('L\'accès aux photos est nécessaire pour sélectionner des images. Veuillez activer l\'autorisation dans les paramètres.'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Paramètres'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      // First check for permissions
      bool hasPermission = await _handlePermissions();
      if (!hasPermission) {
        return;
      }
      
      // Try picking image using a different approach to handle the issue
      try {
        final XFile? selectedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        
        if (selectedImage != null && _selectedImages.length < _maxImages) {
          setState(() {
            _selectedImages.add(selectedImage);
          });
        }
      } catch (e) {
        // Fall back to picking without compression if the above method fails
        final XFile? selectedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: null, // Try without compression
        );
        
        if (selectedImage != null && _selectedImages.length < _maxImages) {
          setState(() {
            _selectedImages.add(selectedImage);
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }

  Future<void> _publishAd() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner au moins une image')),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        // Generate a unique product ID
        String productId = Uuid().v4();
        List<String> imageUrls = [];

        // Upload images to Firebase Storage
        for (int i = 0; i < _selectedImages.length; i++) {
          XFile image = _selectedImages[i];
          String imagePath = 'products/$productId/image_$i.jpg';
          Reference storageRef = _storage.ref().child(imagePath);
          
          File imageFile = File(image.path);
          
          // Check if file exists and is readable
          if (!await imageFile.exists()) {
            throw Exception('Image file does not exist: ${image.path}');
          }
          
          // Upload image with retry logic
          await _uploadWithRetry(storageRef, imageFile);
          
          // Get download URL
          String downloadUrl = await storageRef.getDownloadURL();
          imageUrls.add(downloadUrl);
        }

        // Create product data
        Map<String, dynamic> productData = {
          'category': widget.category?.id,
          'categoryImageUrl' : widget.category?.imageUrl,
          'categoryName' : widget.category?.name,
          'subcategory': widget.subcategory,
          'wilaya': widget.wilaya,
          'commune': widget.commune,
          'title': _titleController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'imagesUrl': imageUrls,
          'createdAt': FieldValue.serverTimestamp(),
          'userID': FirebaseAuth.instance.currentUser?.uid, // Replace with actual user ID
          'isAdvertising': false,
          'isBestSeller': false,
          'rating' : 0.0,
          'visible' : true,
        };

        // Add product to Firestore
        await _firestore.collection('products').doc(productId).set(productData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Annonce publiée avec succès!')),
        );

        // Navigate back to home or product listing page
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        print('Error publishing ad: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la publication: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
  
  // Upload with retry logic
  Future<void> _uploadWithRetry(Reference ref, File file, {int retries = 3}) async {
    int attempts = 0;
    while (attempts < retries) {
      try {
        await ref.putFile(file);
        return; // Success
      } catch (e) {
        attempts++;
        if (attempts >= retries) {
          throw e; // Rethrow after all retries failed
        }
        await Future.delayed(Duration(seconds: 2)); // Wait before retry
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Étape 2'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Photos (Maximum 5)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              
              // Image selection grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _maxImages,
                itemBuilder: (context, index) {
                  return index < _selectedImages.length
                      ? Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImages[index].path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : InkWell(
                          onTap: _selectedImages.length < _maxImages
                              ? () => _pickImage()
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedImages.length < _maxImages
                                    ? Colors.grey
                                    : Colors.grey.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate,
                              color: _selectedImages.length < _maxImages
                                  ? Colors.grey
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        );
                },
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre de l\'annonce',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un titre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Prix de l\'annonce',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un prix';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description de l\'annonce',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isUploading ? null : _publishAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isUploading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Publication en cours...',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      )
                    : Text(
                        'Publier',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}