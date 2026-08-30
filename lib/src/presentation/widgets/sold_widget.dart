import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SoldWidget extends StatelessWidget {
  const SoldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '0.00 DZD',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40.sp,
              fontFamily: 'Kumbh Sans',
              fontWeight: FontWeight.w600,
            ),
          );
        }
        final String sold = double.parse(
          snapshot.data?['sold'].toString() ?? '0.0',
        ).toStringAsFixed(2);

        return Text(
          '$sold DZD',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white,
            fontSize: 40.sp,
            fontFamily: 'Kumbh Sans',
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
