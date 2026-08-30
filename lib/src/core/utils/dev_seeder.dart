import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Peuple Firestore avec un catalogue de démonstration : catégories,
/// sous-catégories, produits (avec images externes, sans Firebase Storage),
/// publicités. Certains produits sont attribués à l'utilisateur courant pour
/// alimenter « Mes annonces » et son historique de ventes.
///
/// Idempotent : protégé par le drapeau `app_meta/dev_seed`.
class DevSeeder {
  DevSeeder._();

  static const int _version = 1;
  static bool _ranThisSession = false;

  static String _img(String keywords, int lock) =>
      'https://loremflickr.com/800/600/${Uri.encodeComponent(keywords)}?lock=$lock';

  /// Photo de catégorie (URL Unsplash stable).
  static const Map<String, String> _categoryImage = {
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
    'Vêtements':
        'https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=800&q=80',
  };

  static const Map<String, List<String>> _subcategories = {
    'Voitures': ['Berlines', 'SUV', 'Sportives'],
    'Ordinateurs': ['Portables', 'PC de Bureau', 'Accessoires'],
    'Motos': ['Sport', 'Custom', 'Trail'],
    'Photographie': ['Appareils photo', 'Objectifs', 'Éclairage'],
    'Meubles': ['Salon', 'Chambre', 'Bureau'],
    'Vêtements': ['Homme', 'Femme', 'Chaussures'],
  };

  static const Map<String, String> _keyword = {
    'Voitures': 'car',
    'Ordinateurs': 'laptop',
    'Motos': 'motorcycle',
    'Photographie': 'camera',
    'Meubles': 'furniture',
    'Vêtements': 'fashion',
  };

  /// Produits par catégorie : titre, prix, note, sous-catégorie, description.
  static const Map<String, List<Map<String, dynamic>>> _products = {
    'Voitures': [
      {'title': 'Mercedes-Benz Classe A', 'price': '32000', 'rating': 4.8, 'subcategory': 'Berlines', 'description': 'Mercedes Classe A 2023, faible kilométrage, intérieur cuir, GPS, caméra de recul.'},
      {'title': 'Peugeot 3008 SUV', 'price': '29900', 'rating': 4.7, 'subcategory': 'SUV', 'description': 'Peugeot 3008 2021, diesel, 7 places, i-Cockpit, sièges chauffants.'},
      {'title': 'Renault Clio RS', 'price': '18500', 'rating': 4.5, 'subcategory': 'Sportives', 'description': 'Clio RS essence, sportive et économique, écran tactile, clim auto.'},
    ],
    'Ordinateurs': [
      {'title': 'MacBook Pro 16"', 'price': '2499', 'rating': 4.9, 'subcategory': 'Portables', 'description': 'MacBook Pro M1 Pro, 16 Go RAM, 1 To SSD, écran Liquid Retina XDR.'},
      {'title': 'Dell XPS 13', 'price': '1299', 'rating': 4.6, 'subcategory': 'Portables', 'description': 'Ultra-portable InfinityEdge, Core i7, 16 Go, 512 Go SSD, châssis alu.'},
      {'title': 'PC Gamer RTX 4070', 'price': '1899', 'rating': 4.7, 'subcategory': 'PC de Bureau', 'description': 'Tour gaming Ryzen 9, RTX 4070, 32 Go RAM, refroidissement liquide.'},
    ],
    'Motos': [
      {'title': 'Yamaha MT-07', 'price': '7499', 'rating': 4.7, 'subcategory': 'Sport', 'description': 'Yamaha MT-07 2022, 689 cc, 5 000 km, excellente maniabilité.'},
      {'title': 'Honda CBR650R', 'price': '9299', 'rating': 4.8, 'subcategory': 'Sport', 'description': 'Honda CBR650R sportive, 4 cylindres, freins Nissin, fourche Showa.'},
      {'title': 'Kawasaki Z900', 'price': '8999', 'rating': 4.6, 'subcategory': 'Custom', 'description': 'Kawasaki Z900 2023, naked 948 cc, échappement Akrapovic, kit carénage.'},
    ],
    'Photographie': [
      {'title': 'Canon EOS R6', 'price': '2499', 'rating': 4.9, 'subcategory': 'Appareils photo', 'description': 'Hybride plein format 20 MP, stabilisation 8 stops, vidéo 4K, RF 24-105 f/4L.'},
      {'title': 'Sony Alpha A7 III', 'price': '1999', 'rating': 4.8, 'subcategory': 'Appareils photo', 'description': 'Plein format 24 MP, stabilisation 5 axes, AF rapide, grande autonomie.'},
      {'title': 'Objectif Sigma 35mm f/1.4', 'price': '699', 'rating': 4.7, 'subcategory': 'Objectifs', 'description': 'Focale fixe Art, ouverture f/1.4, piqué exceptionnel, monture E/EF.'},
    ],
    'Meubles': [
      {'title': "Canapé d'angle scandinave", 'price': '1299', 'rating': 4.5, 'subcategory': 'Salon', 'description': "Canapé d'angle 5 places, tissu gris clair, pieds bois, convertible + coffre."},
      {'title': 'Lit King Size avec rangements', 'price': '899', 'rating': 4.6, 'subcategory': 'Chambre', 'description': 'Lit 180x200, tête capitonnée, 4 tiroirs, bois massif chêne naturel.'},
      {'title': 'Bureau design industriel', 'price': '499', 'rating': 4.7, 'subcategory': 'Bureau', 'description': 'Plateau bois massif 140x80, structure métal noir, 2 tiroirs + étagère.'},
    ],
    'Vêtements': [
      {'title': 'Manteau laine homme', 'price': '189', 'rating': 4.7, 'subcategory': 'Homme', 'description': 'Manteau laine coupe slim, doublure chaude, noir / gris / bleu marine, S-XXL.'},
      {'title': 'Robe de soirée élégante', 'price': '159', 'rating': 4.8, 'subcategory': 'Femme', 'description': 'Robe longue satinée, détails perlés, bordeaux, fendue sur le côté.'},
      {'title': 'Baskets running performance', 'price': '129', 'rating': 4.6, 'subcategory': 'Chaussures', 'description': 'Baskets légères et respirantes, semelle amortissante, plusieurs coloris.'},
    ],
  };

  static const List<String> _otherSellers = [
    'seller_yacine',
    'seller_karim',
    'seller_sofiane',
    'seller_amine',
  ];

  static Future<void> run() async {
    if (_ranThisSession) return;
    _ranThisSession = true;

    final firestore = FirebaseFirestore.instance;
    final flagRef = firestore.collection('app_meta').doc('dev_seed');
    final uid = FirebaseAuth.instance.currentUser?.uid;

    try {
      final flag = await flagRef.get();
      if (flag.exists && (flag.data()?['version'] ?? 0) >= _version) return;

      // Nettoyage d'un éventuel semis partiel (échec d'une exécution précédente).
      for (final col in ['categories', 'products', 'advertisements']) {
        final snap = await firestore.collection(col).get();
        for (var i = 0; i < snap.docs.length; i += 400) {
          final batch = firestore.batch();
          for (final d in snap.docs.skip(i).take(400)) {
            batch.delete(d.reference);
          }
          await batch.commit();
        }
      }

      int lock = 1;
      var productIndex = 0;

      for (final entry in _categoryImage.entries) {
        final catName = entry.key;
        final subs = _subcategories[catName]!;
        final catImage = entry.value;
        final kw = _keyword[catName]!;

        // Catégorie
        final catRef = await firestore.collection('categories').add({
          'name': catName,
          'imageUrl': catImage,
          'count': _products[catName]!.length,
          'subcategories': subs,
        });

        // Produits
        for (final p in _products[catName]!) {
          // 1 produit sur 3 appartient à l'utilisateur courant (profil Sadek)
          final bool mine = uid != null && productIndex % 3 == 0;
          final sellerId = mine
              ? uid
              : _otherSellers[productIndex % _otherSellers.length];

          await firestore.collection('products').add({
            'category': catRef.id,
            'categoryName': catName,
            'categoryImageUrl': catImage,
            'subcategory': p['subcategory'],
            'title': p['title'],
            'price': p['price'],
            'rating': p['rating'],
            'imagesUrl': [
              _img(kw, lock++),
              _img(kw, lock++),
              _img('$kw,${p['subcategory']}', lock++),
            ],
            'description': p['description'],
            'userID': sellerId,
            'visible': true,
            'isAdvertising': productIndex % 4 == 0,
            'isBestSeller': productIndex % 5 == 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
          productIndex++;
        }
      }

      // Publicités
      for (final adKw in ['sale', 'shopping', 'store', 'discount']) {
        await firestore.collection('advertisements').add({
          'imageUrl': _img(adKw, lock++),
          'title': 'Offres Dinari',
        });
      }

      // Vendeurs fictifs : numéro de téléphone affichable au bouton « Call »
      for (var i = 0; i < _otherSellers.length; i++) {
        await firestore.collection('users').doc(_otherSellers[i]).set({
          'fullName': const [
            'Yacine Belkacem',
            'Karim Meziane',
            'Sofiane Haddad',
            'Amine Torki',
          ][i],
          'phoneNumber': '07${70 + i}${100000 + i * 137}',
          'email': '${_otherSellers[i]}@dinari.dz',
        }, SetOptions(merge: true));
      }

      await flagRef.set({
        'version': _version,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('=> DevSeeder: catalogue de démonstration créé');
    } catch (e) {
      debugPrint('=> DevSeeder error: $e');
    }
  }
}
