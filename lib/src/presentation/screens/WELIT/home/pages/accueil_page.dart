import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dinari/src/database/models/user_model.dart';
import 'package:dinari/src/presentation/widgets/banking_menu_widget.dart';
import 'package:dinari/src/presentation/widgets/sold_widget.dart';
import 'package:dinari/src/presentation/widgets/transaction_history_widget.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AccueilPage extends StatefulWidget {
  final UserModel user;
  const AccueilPage({super.key, required this.user});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  @override
  void initState() {
    super.initState();
    _seedFakeOperationsIfEmpty();
  }

  /// Version courante de l'historique fictif. Incrémenter pour forcer un
  /// re-remplissage chez les comptes déjà semés.
  static const int _opsSeedVersion = 2;

  /// Insère (ou met à jour) un historique de transactions fictif :
  /// recharges, envois, réceptions, transferts + historique d'achats et de
  /// ventes, chacun avec un numéro de référence pour la traçabilité.
  Future<void> _seedFakeOperationsIfEmpty() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      final opsRef = userRef.collection('operations');

      final userSnap = await userRef.get();
      final currentVersion =
          (userSnap.data()?['opsSeedVersion'] ?? 0) as int;
      if (currentVersion >= _opsSeedVersion) return;

      // Nettoyage de l'ancien historique fictif avant re-remplissage.
      final existingOps = await opsRef.get();

      final now = DateTime.now();
      final fake = <Map<String, dynamic>>[
        {
          'type': 'Recharge',
          'amount': 5000.0,
          'counterparty': 'Carte de recharge Dinari',
          'reference': 'RCH-10245',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        },
        {
          'type': 'Envoi',
          'amount': -1200.0,
          'counterparty': 'Karim Meziane',
          'reference': 'ENV-88431',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 3))),
        },
        {
          'type': 'Paiement',
          'amount': -3499.99,
          'counterparty': 'Boutique El Djazaïr',
          'reference': 'PAY-55217',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 2, hours: 6))),
        },
        {
          'type': 'Reception',
          'amount': 8000.0,
          'counterparty': 'Sofiane Haddad',
          'reference': 'REC-73900',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 3, hours: 1))),
        },
        {
          'type': 'Transfert',
          'amount': -2500.0,
          'counterparty': 'Compte épargne',
          'reference': 'TRF-40118',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 5, hours: 4))),
        },
        {
          'type': 'Recharge',
          'amount': 10000.0,
          'counterparty': 'Carte de recharge Dinari',
          'reference': 'RCH-10099',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 8, hours: 2))),
        },
        {
          'type': 'Envoi',
          'amount': -750.50,
          'counterparty': 'Nadia Cherif',
          'reference': 'ENV-88012',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 12, hours: 9))),
        },
        // --- Historique d'achats ---
        {
          'type': 'Achat',
          'amount': -8999.0,
          'counterparty': 'Yacine Belkacem · Kawasaki Z900',
          'reference': 'PUR-20451',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 4, hours: 5))),
        },
        {
          'type': 'Achat',
          'amount': -1299.0,
          'counterparty': 'Boutique El Djazaïr · Dell XPS 13',
          'reference': 'PUR-20512',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 9, hours: 2))),
        },
        {
          'type': 'Achat',
          'amount': -159.0,
          'counterparty': 'Amine Torki · Robe de soirée',
          'reference': 'PUR-20588',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 15, hours: 7))),
        },
        // --- Historique de ventes ---
        {
          'type': 'Vente',
          'amount': 7499.0,
          'counterparty': 'Karim Meziane · Yamaha MT-07',
          'reference': 'SAL-30177',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 6, hours: 3))),
        },
        {
          'type': 'Vente',
          'amount': 2499.0,
          'counterparty': 'Sofiane Haddad · Canon EOS R6',
          'reference': 'SAL-30240',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 11, hours: 1))),
        },
        {
          'type': 'Vente',
          'amount': 499.0,
          'counterparty': 'Nadia Cherif · Bureau design industriel',
          'reference': 'SAL-30312',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 18, hours: 6))),
        },
      ];

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in existingOps.docs) {
        batch.delete(doc.reference);
      }
      for (final op in fake) {
        batch.set(opsRef.doc(), op);
      }
      batch.set(userRef, {'opsSeedVersion': _opsSeedVersion},
          SetOptions(merge: true));
      await batch.commit();
    } catch (e) {
      debugPrint('=> Erreur seed operations fictives : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: GradiantWidget(
        widget: SafeArea(
          bottom: false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  8.verticalSpace,
                  Text(
                    'Bonjour, ${widget.user.fullName.split(' ').first}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  8.verticalSpace,
                  IconButton(
                    onPressed: () {
                      context.go('/home-welit/charge-welit');
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 70.r,
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                  8.verticalSpace,
                  Text(
                    'Dinari : Solde disponible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFEBFFEE),
                      fontSize: 14.sp,
                      fontFamily: 'Kumbh Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  8.verticalSpace,
                  SoldWidget(),
                  8.verticalSpace,
                  const Spacer(),

                  TransactionHistoryWidget(),
                ],
              ),
              Positioned(
                right: 0,
                left: 0,
                bottom: 340.h,
                child: BankingMenuWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



