import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/database/models/operation_model.dart';
import 'package:dinari/src/presentation/widgets/transaction_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'Transfert':
        return Icons.swap_horiz;
      case 'Recharge':
        return Icons.account_balance_wallet;
      case 'Reception':
        return Icons.arrow_upward;
      case 'Paiement':
      case 'Achat':
        return Icons.shopping_bag_outlined;
      case 'Vente':
        return Icons.sell_outlined;
      default:
        return Icons.arrow_downward;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des opérations')),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('operations')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('Aucune opération pour le moment'),
            );
          }
          return Padding(
            padding: REdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final operation = OperationModel.fromFirestore(docs[index]);

                return TransactionItem(
                  icon: _iconFor(operation.type),
                  iconBackgroundColor: Colors.teal,
                  title: operation.type,
                  date: operation.date,
                  amount: operation.amount,
                  currency: 'DZD',
                  onTap: () => context.push(
                    '/home-welit/operation-detail-welit',
                    extra: operation,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
