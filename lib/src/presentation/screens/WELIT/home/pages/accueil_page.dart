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

  /// Insère un historique de transactions fictif la première fois
  /// (uniquement si la sous-collection `operations` est vide).
  Future<void> _seedFakeOperationsIfEmpty() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final opsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('operations');

      final existing = await opsRef.limit(1).get();
      if (existing.docs.isNotEmpty) return;

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
      ];

      final batch = FirebaseFirestore.instance.batch();
      for (final op in fake) {
        batch.set(opsRef.doc(), op);
      }
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



