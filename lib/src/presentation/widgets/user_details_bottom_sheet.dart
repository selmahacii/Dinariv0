import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UserDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const UserDetailsBottomSheet({
    super.key,
    required this.userData,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Extract user data (with fallbacks for missing fields)
    final String fullName = userData['fullName'] ?? 'Utilisateur';
    final String phone = userData['phoneNumber'] ?? 'Non disponible';
    final String email = userData['email'] ?? 'Non disponible';
    final String photoUrl = userData['photoUrl'] ?? '';
    final num balance = userData['sold'] ?? 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with handle bar
          Container(
            padding: REdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Container(
              width: 40.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5.r),
              ),
            ),
          ),

          // User avatar and verification animation
          Padding(
            padding: REdgeInsets.symmetric(vertical: 16),
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.teal.shade50,
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child:
                  photoUrl.isEmpty
                      ? Icon(Icons.person, size: 60.r, color: Colors.teal)
                      : null,
            ),
          ),

          // User name
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kumbh Sans',
            ),
          ),

          // User ID
          Text(
            'ID: $userId',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              fontFamily: 'Kumbh Sans',
            ),
          ),

          20.verticalSpace,

          // Balance display
          // Container(
          //   margin: REdgeInsets.symmetric(horizontal: 24),
          //   padding: REdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [Colors.teal.shade300, Colors.teal.shade600],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ),
          //     borderRadius: BorderRadius.circular(16.r),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.teal.withOpacity(0.3),
          //         blurRadius: 10,
          //         spreadRadius: 1,
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'Solde du compte',
          //         style: TextStyle(
          //           fontSize: 14.sp,
          //           color: Colors.white.withOpacity(0.8),
          //           fontFamily: 'Kumbh Sans',
          //         ),
          //       ),
          //       8.verticalSpace,
          //       Text(
          //         '${balance.toStringAsFixed(2)} DA',
          //         style: TextStyle(
          //           fontSize: 28.sp,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.white,
          //           fontFamily: 'Kumbh Sans',
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // 24.verticalSpace,

          // User details cards
          Padding(
            padding: REdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildInfoCard(Icons.phone, 'Téléphone', phone),
                12.verticalSpace,
                _buildInfoCard(Icons.email, 'Email', email),
              ],
            ),
          ),

          const Spacer(),

          // Action buttons
          Padding(
            padding: REdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: REdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Fermer',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      context.go(
                        '/home-welit/money-transfer-welit',
                        extra: userId,
                      );
                      // Here you could add additional functionality like initiating a payment
                      // to this user or another action
                    },
                    style: ElevatedButton.styleFrom(
                      padding: REdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Envoyer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: REdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: REdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.teal, size: 20.r),
          ),
          16.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontFamily: 'Kumbh Sans',
                ),
              ),
              4.verticalSpace,
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Kumbh Sans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
