import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/app/error_app.dart';
import 'package:dinari/src/app/my_app.dart';
import 'package:dinari/src/core/setting/app_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppSetting.instance.init();
    // await addCategoriesWithPicsumImages();
    // await addProductsToFirestore();c
    // await addAdvertisementsToFirestore();
    // await addCategoryLinkedAdvertisements();
    // await addFeaturedProductAdvertisements();
    runApp(const MyApp());
  } catch (e, st) {
    debugPrint('=> Error launching app : ${e.toString()}\n${st.toString()}');
    runApp(const ErrorApp());
  }
}




Future<void> addCategoriesWithPicsumImages() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // Function to generate a random Picsum image
  String getRandomPicsumUrl() {
    final width = 600;
    final height = 400;
    final randomId = Random().nextInt(1000);
    return 'https://picsum.photos/id/$randomId/$width/$height';
  }
  
  // Map of categories with their sub-categories
  final Map<String, List<String>> categoriesWithSubcategories = {
    'Voitures': ['Berlines', 'SUV', 'Utilitaires', 'Cabriolets', 'Sportives'],
    'Ordinateurs': ['Portables', 'PC de Bureau', 'Tablettes', 'Accessoires', 'Pièces détachées'],
    'Motos': ['Sport', 'Custom', 'Trail', 'Scooters', 'Vintage'],
    'Photographie': ['Appareils photo', 'Objectifs', 'Trépieds', 'Éclairage', 'Accessoires'],
    'Meubles': ['Salon', 'Chambre', 'Cuisine', 'Bureau', 'Jardin'],
    'Jeux vidéo': ['Consoles', 'Jeux', 'Accessoires', 'PC Gaming', 'Rétro'],
    'Terres': ['Terrains constructibles', 'Terrains agricoles', 'Jardins', 'Forêts', 'Parcelles'],
    'Vêtements': ['Homme', 'Femme', 'Enfant', 'Chaussures', 'Accessoires']
  };
  
  for (final MapEntry<String, List<String>> entry in categoriesWithSubcategories.entries) {
    final String categoryName = entry.key;
    final List<String> subcategories = entry.value;
    
    try {
      final categoryData = {
        'name': categoryName,
        'imageUrl': getRandomPicsumUrl(),
        'count': 0,
        'subcategories': subcategories
      };
      
      await firestore.collection('categories').add(categoryData);
      print('Added category: $categoryName with ${subcategories.length} subcategories and random Picsum image');
    } catch (e) {
      print('Error adding category $categoryName: $e');
    }
  }
  
  print('All categories with subcategories have been added to Firestore with random Picsum images');
}




Future<void> addProductsToFirestore() async {
  // Get references to Firestore and Authentication
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  // Get current user ID or use a placeholder if not authenticated
  final String currentUserID = auth.currentUser?.uid ?? 'admin123';
  
  // Get all categories from Firestore
  final QuerySnapshot categoriesSnapshot = 
      await firestore.collection('categories').get();
  
  // Map to store category IDs and their data for reference
  final Map<String, Map<String, dynamic>> categoryMap = {};
  
  // Populate the category map
  for (final doc in categoriesSnapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    categoryMap[doc.id] = {
      'name': data['name'] as String,
      'imageUrl': data['imageUrl'] as String,
      'subcategories': data['subcategories'] as List<dynamic>
    };
  }
  
  // Function to generate random Picsum image URLs
  String getRandomPicsumUrl() {
    final width = 600;
    final height = 400;
    final randomId = Random().nextInt(1000);
    return 'https://picsum.photos/id/$randomId/$width/$height';
  }
  
  // Function to generate multiple random Picsum image URLs
  List<String> getRandomPicsumUrls(int count) {
    List<String> urls = [];
    for (int i = 0; i < count; i++) {
      urls.add(getRandomPicsumUrl());
    }
    return urls;
  }
  
  // Product data for each category
  final Map<String, List<Map<String, dynamic>>> productsByCategory = {
    'Voitures': [
      {
        'title': 'Mercedes-Benz Classe A',
        'price': '32000',
        'rating': 4.8,
        'description': 'Mercedes-Benz Classe A 2023, excellent état, faible kilométrage, noir métallisé avec intérieur cuir beige. Équipements premium incluant navigation GPS, caméra de recul et toit ouvrant panoramique.',
        'subcategory': 'Berlines',
      },
      {
        'title': 'Renault Clio',
        'price': '18500',
        'rating': 4.5,
        'description': 'Renault Clio 2022, 5 portes, essence, économique et pratique pour la ville. Système multimédia avec écran tactile, climatisation automatique et capteurs de stationnement.',
        'subcategory': 'Berlines',
      },
      {
        'title': 'Peugeot 3008 SUV',
        'price': '29900',
        'rating': 4.7,
        'description': 'Peugeot 3008 SUV 2021, diesel, gris artense, 7 places. Parfait pour les familles avec grand coffre, sièges chauffants et système i-Cockpit innovant.',
        'subcategory': 'SUV',
      },
    ],
    'Ordinateurs': [
      {
        'title': 'MacBook Pro 16"',
        'price': '2499',
        'rating': 4.9,
        'description': 'MacBook Pro 16" avec puce M1 Pro, 16GB RAM, 1TB SSD. Parfait pour les professionnels et créatifs. Écran Liquid Retina XDR et autonomie exceptionnelle.',
        'subcategory': 'Portables',
      },
      {
        'title': 'ASUS ROG Gaming',
        'price': '1899',
        'rating': 4.7,
        'description': 'ASUS ROG Strix G15, processeur AMD Ryzen 9, RTX 3070, 32GB RAM. Performances optimales pour le gaming avec système de refroidissement avancé.',
        'subcategory': 'Portables',
      },
      {
        'title': 'Dell XPS 13',
        'price': '1299',
        'rating': 4.6,
        'description': 'Dell XPS 13 ultra-portable avec écran InfinityEdge, Intel Core i7, 16GB RAM et 512GB SSD. Design premium avec châssis en aluminium et autonomie toute la journée.',
        'subcategory': 'Portables',
      },
    ],
    'Motos': [
      {
        'title': 'Yamaha MT-07',
        'price': '7499',
        'rating': 4.7,
        'description': 'Yamaha MT-07 2022, 689cc, bleu nuit. Excellente maniabilité et performances, idéale pour conducteurs intermédiaires. Seulement 5000km au compteur.',
        'subcategory': 'Sport',
      },
      {
        'title': 'Honda CBR650R',
        'price': '9299',
        'rating': 4.8,
        'description': 'Honda CBR650R sportive, 4 cylindres, rouge passion. Parfaite pour la route et les circuits. Freins Nissin et fourche Showa réglable.',
        'subcategory': 'Sport',
      },
      {
        'title': 'Kawasaki Z900',
        'price': '8999',
        'rating': 4.6,
        'description': 'Kawasaki Z900 2023, naked bike puissante et agressive avec son moteur 948cc. Ligne d\'échappement Akrapovic et kit carénage inclus.',
        'subcategory': 'Custom',
      },
    ],
    'Photographie': [
      {
        'title': 'Canon EOS R6',
        'price': '2499',
        'rating': 4.9,
        'description': 'Canon EOS R6 hybride plein format, 20MP, stabilisation 8 stops. Idéal pour photo et vidéo 4K. Livré avec objectif RF 24-105mm f/4L IS USM.',
        'subcategory': 'Appareils photo',
      },
      {
        'title': 'Sony Alpha A7 III',
        'price': '1999',
        'rating': 4.8,
        'description': 'Sony Alpha A7 III plein format, 24MP, stabilisation 5 axes. Excellente sensibilité ISO et mise au point automatique. Autonomie exceptionnelle.',
        'subcategory': 'Appareils photo',
      },
      {
        'title': 'Nikon Z6 II',
        'price': '2199',
        'rating': 4.7,
        'description': 'Nikon Z6 II hybride polyvalent, double processeur EXPEED 6, rafale 14 FPS. Vidéo 4K60p et connectivité étendue. Corps uniquement.',
        'subcategory': 'Appareils photo',
      },
    ],
    'meubles': [
      {
        'title': 'Canapé d\'angle Scandinave',
        'price': '1299',
        'rating': 4.5,
        'description': 'Canapé d\'angle style scandinave, 5 places, tissu gris clair, pieds en bois. Convertible avec coffre de rangement. Dimensions: 280x210x85cm.',
        'subcategory': 'Salon',
      },
      {
        'title': 'Lit King Size avec rangements',
        'price': '899',
        'rating': 4.6,
        'description': 'Lit King Size 180x200cm avec tête de lit capitonnée et 4 tiroirs de rangement. Structure en bois massif, coloris chêne naturel.',
        'subcategory': 'Chambre',
      },
      {
        'title': 'Bureau Design Industriel',
        'price': '499',
        'rating': 4.7,
        'description': 'Bureau design industriel avec plateau en bois massif 140x80cm et structure en métal noir. Comprend 2 tiroirs et étagère intégrée.',
        'subcategory': 'Bureau',
      },
    ],
    'Jeux vidéo': [
      {
        'title': 'PlayStation 5 Digital Edition',
        'price': '399',
        'rating': 4.8,
        'description': 'Console PlayStation 5 Digital Edition avec manette DualSense. Stockage SSD 825GB, lecteur Blu-ray 4K et compatibilité VR. Neuve sous blister.',
        'subcategory': 'Consoles',
      },
      {
        'title': 'Nintendo Switch OLED',
        'price': '349',
        'rating': 4.7,
        'description': 'Nintendo Switch modèle OLED avec écran 7 pouces, station d\'accueil avec port Ethernet, mémoire interne de 64 Go et audio amélioré.',
        'subcategory': 'Consoles',
      },
      {
        'title': 'Xbox Series X',
        'price': '499',
        'rating': 4.9,
        'description': 'Console Xbox Series X 1TB SSD avec manette sans fil. Jeu en 4K à 120FPS, temps de chargement ultra-rapides et rétrocompatibilité étendue.',
        'subcategory': 'Consoles',
      },
    ],
    'Terres': [
      {
        'title': 'Terrain Constructible 1000m²',
        'price': '85000',
        'rating': 4.6,
        'description': 'Terrain constructible de 1000m² proche de Bordeaux. Viabilisé avec eau, électricité et tout-à-l\'égout. Exposition sud et vue dégagée.',
        'subcategory': 'Terrains constructibles',
      },
      {
        'title': 'Parcelle Agricole 2 Hectares',
        'price': '45000',
        'rating': 4.5,
        'description': 'Parcelle agricole de 2 hectares, terre fertile adaptée à diverses cultures. Accès facile et possibilité d\'irrigation. Située à 15km de Lyon.',
        'subcategory': 'Terrains agricoles',
      },
      {
        'title': 'Terrain Boisé 5000m²',
        'price': '29000',
        'rating': 4.4,
        'description': 'Terrain boisé de 5000m² avec diverses essences (chênes, châtaigniers). Idéal pour loisirs ou petit projet écologique. Non constructible.',
        'subcategory': 'Forêts',
      },
    ],
    'Vêtements': [
      {
        'title': 'Manteau Laine Homme',
        'price': '189',
        'rating': 4.7,
        'description': 'Manteau en laine pour homme, coupe slim, doublure intérieure chaude. Disponible en noir, gris ou bleu marine. Tailles S à XXL.',
        'subcategory': 'Homme',
      },
      {
        'title': 'Robe de Soirée Élégante',
        'price': '159',
        'rating': 4.8,
        'description': 'Robe de soirée longue, tissu satiné avec détails perlés. Couleur bordeaux, fendue sur le côté. Parfaite pour les événements formels.',
        'subcategory': 'Femme',
      },
      {
        'title': 'Baskets Running Performance',
        'price': '129',
        'rating': 4.6,
        'description': 'Baskets de running légères et respirantes. Semelle amortissante et support de voûte plantaire. Disponibles en plusieurs coloris.',
        'subcategory': 'Chaussures',
      },
    ],
  };
  
  // Add products to Firestore
  for (final categoryId in categoryMap.keys) {
    final categoryData = categoryMap[categoryId]!;
    final categoryName = categoryData['name'] as String;
    
    // Get product list for this category (or use empty list if not found)
    final productList = productsByCategory[categoryName] ?? [];
    
    // Skip if no products defined for this category
    if (productList.isEmpty) {
      print('No products defined for category: $categoryName');
      continue;
    }
    
    // Add each product
    for (final product in productList) {
      try {
        // Generate 2-4 random images for the product
        final imageCount = 2 + Random().nextInt(3); // Random between 2 and 4
        final List<String> imageUrls = getRandomPicsumUrls(imageCount);
        
        // Randomly assign advertising and bestseller flags (about 30% chance for each)
        final bool isAdvertising = Random().nextDouble() < 0.3;
        final bool isBestSeller = Random().nextDouble() < 0.3;
        
        // Create product data
        final productData = {
          'category': categoryId,
          'categoryName': categoryName,
          'categoryImageUrl': categoryData['imageUrl'],
          'subcategory': product['subcategory'],
          'title': product['title'],
          'price': product['price'],
          'rating': product['rating'],
          'imagesUrl': imageUrls,
          'description': product['description'],
          'userID': currentUserID,
          'visible': true,
          'isAdvertising': isAdvertising,
          'isBestSeller': isBestSeller,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Add to Firestore
        await firestore.collection('products').add(productData);
        print('Added product: ${product['title']} to category: $categoryName, subcategory: ${product['subcategory']}');
        
        // Update category count
        await firestore.collection('categories').doc(categoryId).update({
          'count': FieldValue.increment(1)
        });
        
      } catch (e) {
        print('Error adding product ${product['title']}: $e');
      }
    }
  }
  
  print('All products have been added to Firestore');
}