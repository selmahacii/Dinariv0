import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Remplace les images génériques (picsum) des catégories / produits /
/// publicités par des photos thématiques provenant d'une ressource externe
/// (LoremFlickr — images réelles filtrées par mots-clés).
///
/// L'opération est protégée par un drapeau Firestore (`app_meta/marketplace_images`)
/// et ne s'exécute donc qu'une seule fois par projet.
class MarketplaceImageSeeder {
  MarketplaceImageSeeder._();

  static const int _version = 4;
  static bool _ranThisSession = false;

  static const String _base = 'https://loremflickr.com/800/600';
  static const String _u =
      '?auto=format&fit=crop&w=800&q=80'; // suffixe Unsplash

  /// 3 photos Unsplash sélectionnées par catégorie (utilisées pour les produits).
  static const Map<String, List<String>> _categoryProductImages = {
    'Voitures': [
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
      'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d',
      'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7',
    ],
    'Ordinateurs': [
      'https://images.unsplash.com/photo-1496181133206-80ce9b88a853',
      'https://images.unsplash.com/photo-1517336714731-489689fd1ca8',
      'https://images.unsplash.com/photo-1541807084-5c52b6b3adef',
    ],
    'Motos': [
      'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87',
      'https://images.unsplash.com/photo-1558981806-ec527fa84c39',
      'https://images.unsplash.com/photo-1449426468159-d96dbf08f19f',
    ],
    'Photographie': [
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32',
      'https://images.unsplash.com/photo-1502920917128-1aa500764cbd',
      'https://images.unsplash.com/photo-1500634245200-e5245c7574ef',
    ],
    'Meubles': [
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc',
      'https://images.unsplash.com/photo-1567016432779-094069958ea5',
      'https://images.unsplash.com/photo-1493809842364-78817add7ffb',
    ],
    'Jeux vidéo': [
      'https://images.unsplash.com/photo-1550745165-9bc0b252726f',
      'https://images.unsplash.com/photo-1493711662062-fa541adb3fc8',
      'https://images.unsplash.com/photo-1531525645387-7f14be1bdbbd',
    ],
    'Terres': [
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
      'https://images.unsplash.com/photo-1416879595882-3373a0480b5b',
      'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735',
    ],
    'Vêtements': [
      'https://images.unsplash.com/photo-1445205170230-053b83016050',
      'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f',
      'https://images.unsplash.com/photo-1483985988355-763728e1935b',
    ],
  };

  /// Photos de catégories sélectionnées (URLs Unsplash stables).
  static const Map<String, String> _categoryImages = {
    'Voitures':
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
    'Ordinateurs':
        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80',
    'Motos':
        'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=800&q=80',
    'Photographie':
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80',
    'Meubles':
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=800&q=80',
    'Jeux vidéo':
        'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=800&q=80',
    'Terres':
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
    'Vêtements':
        'https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=800&q=80',
  };

  /// Mot-clé unique par catégorie (fallback LoremFlickr).
  static const Map<String, String> _categoryKeywords = {
    'Voitures': 'car',
    'Ordinateurs': 'laptop',
    'Motos': 'motorcycle',
    'Photographie': 'camera',
    'Meubles': 'furniture',
    'Jeux vidéo': 'videogame',
    'Terres': 'field',
    'Vêtements': 'fashion',
  };

  /// Mot-clé unique par sous-catégorie (meilleurs résultats sur LoremFlickr).
  static const Map<String, String> _subcategoryKeywords = {
    // Voitures
    'Berlines': 'sedan',
    'SUV': 'suv',
    'Utilitaires': 'van',
    'Cabriolets': 'convertible',
    'Sportives': 'sportscar',
    // Ordinateurs
    'Portables': 'laptop',
    'PC de Bureau': 'computer',
    'Tablettes': 'tablet',
    'Accessoires': 'gadget',
    'Pièces détachées': 'motherboard',
    // Motos
    'Sport': 'motorbike',
    'Custom': 'chopper',
    'Trail': 'motocross',
    'Scooters': 'scooter',
    'Vintage': 'motorcycle',
    // Photographie
    'Appareils photo': 'camera',
    'Objectifs': 'lens',
    'Trépieds': 'tripod',
    'Éclairage': 'softbox',
    // Meubles
    'Salon': 'sofa',
    'Chambre': 'bedroom',
    'Cuisine': 'kitchen',
    'Jardin': 'patio',
    // Jeux vidéo
    'Consoles': 'playstation',
    'Jeux': 'videogame',
    'PC Gaming': 'gamingpc',
    'Rétro': 'arcade',
    // Terres
    'Terrains constructibles': 'plot',
    'Terrains agricoles': 'farmland',
    'Jardins': 'garden',
    'Forêts': 'forest',
    'Parcelles': 'meadow',
    // Vêtements
    'Homme': 'menswear',
    'Femme': 'dress',
    'Enfant': 'kidsclothing',
    'Chaussures': 'sneakers',
    // commun
    'Bureau': 'desk',
  };

  static int _lock(String seed, int salt) => (seed.hashCode.abs() % 100000) + salt;

  static String _url(String keywords, String seed, int salt) =>
      '$_base/${Uri.encodeComponent(keywords)}?lock=${_lock(seed, salt)}';

  static String _keywordsFor(String categoryName, String subcategory) {
    if (_subcategoryKeywords.containsKey(subcategory)) {
      return _subcategoryKeywords[subcategory]!;
    }
    return _categoryKeywords[categoryName] ?? 'marketplace,product';
  }

  static Future<void> run() async {
    if (_ranThisSession) return;
    _ranThisSession = true;

    final firestore = FirebaseFirestore.instance;
    final flagRef = firestore.collection('app_meta').doc('marketplace_images');

    try {
      final flag = await flagRef.get();
      if (flag.exists && (flag.data()?['version'] ?? 0) >= _version) {
        return;
      }

      // 1) Catégories
      final categories = await firestore.collection('categories').get();
      final Map<String, String> categoryIdToImage = {};

      var batch = firestore.batch();
      var writes = 0;
      Future<void> flush() async {
        if (writes == 0) return;
        await batch.commit();
        batch = firestore.batch();
        writes = 0;
      }

      for (final doc in categories.docs) {
        final name = (doc.data()['name'] ?? '').toString();
        final url = _categoryImages[name] ??
            _url(_categoryKeywords[name] ?? 'marketplace', doc.id, 0);
        categoryIdToImage[doc.id] = url;
        batch.update(doc.reference, {'imageUrl': url});
        if (++writes >= 400) await flush();
      }
      await flush();

      // 2) Produits (3 images thématiques chacun)
      final products = await firestore.collection('products').get();
      final Set<String> sellerIds = {};
      for (final doc in products.docs) {
        final data = doc.data();
        final categoryName = (data['categoryName'] ?? '').toString();
        final subcategory = (data['subcategory'] ?? '').toString();
        final categoryId = (data['category'] ?? '').toString();
        final sellerId = (data['userID'] ?? '').toString();
        if (sellerId.isNotEmpty) sellerIds.add(sellerId);

        final pool = _categoryProductImages[categoryName];
        final List<String> images;
        if (pool != null) {
          // Rotation stable en fonction de l'id du document.
          final offset = doc.id.hashCode.abs() % pool.length;
          images = [
            for (var k = 0; k < pool.length; k++)
              '${pool[(offset + k) % pool.length]}$_u',
          ];
        } else {
          final kw = _keywordsFor(categoryName, subcategory);
          images = [
            _url(kw, doc.id, 1),
            _url(kw, doc.id, 2),
            _url(kw, doc.id, 3),
          ];
        }

        batch.update(doc.reference, {
          'imagesUrl': images,
          if (categoryIdToImage[categoryId] != null)
            'categoryImageUrl': categoryIdToImage[categoryId],
        });
        if (++writes >= 400) await flush();
      }
      await flush();

      // 2 bis) Vendeurs : garantir un numéro de téléphone (fictif si absent)
      for (final id in sellerIds) {
        final ref = firestore.collection('users').doc(id);
        final snap = await ref.get();
        final data = snap.data();
        final hasPhone =
            (data?['phoneNumber'] ?? '').toString().trim().isNotEmpty;
        if (hasPhone) continue;
        final digits = (id.hashCode.abs() % 100000000).toString().padLeft(8, '0');
        await ref.set({
          'phoneNumber': '0${id.hashCode.isEven ? '6' : '7'}$digits'.substring(0, 10),
          if ((data?['fullName'] ?? '').toString().trim().isEmpty)
            'fullName': 'Vendeur Dinari',
        }, SetOptions(merge: true));
      }

      // 3) Publicités
      final ads = await firestore.collection('advertisements').get();
      var i = 0;
      for (final doc in ads.docs) {
        final data = doc.data();
        final categoryName = (data['categoryName'] ?? '').toString();
        final pool = _categoryProductImages[categoryName];
        final url = pool != null
            ? '${pool[i % pool.length]}$_u'
            : _url(_categoryKeywords[categoryName] ?? 'store,shopping',
                doc.id, 10 + i);
        batch.update(doc.reference, {'imageUrl': url});
        i++;
        if (++writes >= 400) await flush();
      }
      await flush();

      await flagRef.set({
        'version': _version,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('=> MarketplaceImageSeeder: images mises à jour');
    } catch (e) {
      debugPrint('=> MarketplaceImageSeeder error: $e');
    }
  }
}
