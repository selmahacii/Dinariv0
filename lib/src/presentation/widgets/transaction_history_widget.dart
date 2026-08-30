import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/core/utils/constants/app_colors.dart';
import 'package:dinari/src/database/models/operation_model.dart';
import 'package:dinari/src/presentation/widgets/transaction_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TransactionHistoryWidget extends StatelessWidget {
  const TransactionHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: AppColors.instance.surfaceColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          32.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dernières Opérations',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  context.go('/home-welit/operations-welit');
                },
                icon: Text(
                  'See all',
                  style: TextStyle(fontSize: 16.sp, color: Colors.teal),
                ),
                label: Icon(
                  Icons.arrow_forward,
                  color: Colors.teal,
                  size: 16.r,
                ),
              ),
            ],
          ),
          StreamBuilder(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('operations')
                    .limit(10)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Text(
                      'Aucune opération pour le moment',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }
              return Expanded(
                // height: 200.h,
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final operation = OperationModel.fromFirestore(docs[index]);

                    return TransactionItem(
                      icon: _getIcon(operation.type),
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
          16.verticalSpace,
          // // 8.verticalSpace,
          // TransactionItem(
          //   icon: Icons.swap_horiz,
          //   iconBackgroundColor: Colors.teal,
          //   title: 'Transfert',
          //   date: DateTime.now().subtract(const Duration(days: 1)),
          //   amount: -600000,
          //   currency: 'DZD',
          // ),
          // TransactionItem(
          //   icon: Icons.account_balance_wallet,
          //   iconBackgroundColor: Colors.teal,
          //   title: 'Recharge',
          //   date: DateTime(2023, 5, 29),
          //   amount: 260000,
          //   currency: 'DZD',
          // ),
          // TransactionItem(
          //   icon: Icons.arrow_downward,
          //   iconBackgroundColor: Colors.teal,
          //   title: 'Envoi',
          //   date: DateTime(2023, 5, 16),
          //   amount: -350000,
          //   currency: 'DZD',
          // ),
          // TransactionItem(
          //   icon: Icons.arrow_downward,
          //   iconBackgroundColor: Colors.teal,
          //   title: 'Envoi',
          //   date: DateTime(2023, 5, 16),
          //   amount: -350000,
          //   currency: 'DZD',
          // ),
        ],
      ),
    );
  }

  _getIcon(String type) {
    switch (type) {
      case 'Transfert':
        return Icons.swap_horiz;
      case 'Recharge':
        return Icons.account_balance_wallet;
      case 'Envoi':
        return Icons.arrow_downward;
      case 'Reception':
        return Icons.arrow_upward;
      default:
        return Icons.swap_horiz;
    }
  }
}
