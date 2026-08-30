import 'package:dinari/src/presentation/widgets/user_details_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BankingMenuWidget extends StatelessWidget {
  const BankingMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: REdgeInsets.all(16),
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 39,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuIcon('Envoyer', Icons.send, () {
                context.go('/home-welit/contacts-welit');
              }),
              _buildMenuIcon('Recharger', Icons.account_balance_wallet, () {
                context.go('/home-welit/charge-welit');
              }),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildMenuIcon('Transférer', Icons.swap_horiz, () {}),
                  Positioned(right: -10.r, top: -5.r, child: _buildSoonTag()),
                ],
              ),
            ],
          ),
          20.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuIcon('Acheter en ligne', Icons.shopping_cart, () {
                context.go('/home-welit/vendor-space-welit');
              }),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildMenuIcon('mes paiements', Icons.payment, () {
                    context.go('/home-welit/payment-options-welit');
                  }),
                  Positioned(right: -10.r, top: -5.r, child: _buildSoonTag()),
                ],
              ),
              _buildMenuIcon('QR Code', Icons.qr_code_scanner, () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      final currentUser =
                          FirebaseAuth.instance.currentUser?.uid;
                      return Scaffold(
                        appBar: AppBar(),
                        body: SafeArea(
                          // width: 1.sw,
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.only(
                          //     topLeft: Radius.circular(20.r),
                          //     topRight: Radius.circular(20.r),
                          //   ),
                          // ),
                          // padding: EdgeInsets.all(24.r),
                          child: Center(
                            child: Column(
                              // mainAxisSize: MainAxisSize.min,
                              children: [
                                16.verticalSpace,

                                Text(
                                  'Mon code QR',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),

                                8.verticalSpace,

                                Text(
                                  'Partagez ce code pour vous connecter rapidement',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black54,
                                  ),
                                ),

                                24.verticalSpace,

                                // QR Code
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(16.r),
                                  child: QrImageView(
                                    data: 'users/$currentUser',
                                    version: QrVersions.auto,
                                    size: 300.r,
                                    embeddedImage: const AssetImage(
                                      'assets/app_icon.png',
                                    ),
                                    embeddedImageStyle: QrEmbeddedImageStyle(
                                      size: Size(40.r, 40.r),
                                    ),
                                  ),
                                ),

                                16.verticalSpace,

                                Text(
                                  currentUser ?? '',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),

                                8.verticalSpace,

                                Text(
                                  'ID: $currentUser',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black54,
                                  ),
                                ),

                                24.verticalSpace,
                                ElevatedButton(
                                  onPressed: () async {
                                    final result = await context.push('/scan');
                                    if (result != null) {
                                      print('=> Scanned result: $result');
                                      // Process the result
                                      _handleScanResult(
                                        context,
                                        result.toString(),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    minimumSize: Size(0.8.sw, 50),
                                  ),
                                  child: Text(
                                    'Scan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                16.verticalSpace,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _handleScanResult(BuildContext context, String result) {
    // Check if the result follows the expected format: 'users/{userId}'
    if (result.startsWith('users/')) {
      String userId = result.substring(6); // Remove 'users/' prefix
      _verifyUserAndShowInfo(context, userId);
    } else {
      // Invalid QR code format
      _showErrorDialog(
        context,
        'Format de QR code invalide',
        'Le code QR scanné n\'est pas au format attendu.',
      );
    }
  }

  Future<void> _verifyUserAndShowInfo(
    BuildContext context,
    String userId,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: REdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100.r,
                  height: 100.r,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    strokeWidth: 6.r,
                  ),
                ),
                20.verticalSpace,
                Text(
                  'Vérification en cours...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Query Firestore for the user
      final userDoc =
          await FirebaseFirestore.instance.doc('users/$userId').get();

      // Close loading dialog
      Navigator.of(context).pop();

      if (userDoc.exists) {
        // User found, show details
        final userData = userDoc.data() as Map<String, dynamic>;
        _showUserInfoBottomSheet(context, userData, userId);
      } else {
        // User not found
        _showErrorDialog(
          context,
          'Utilisateur introuvable',
          'Aucun utilisateur trouvé avec cet identifiant.',
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      Navigator.of(context).pop();
      _showErrorDialog(
        context,
        'Erreur de connexion',
        'Une erreur s\'est produite lors de la vérification. Veuillez réessayer.',
      );
      print('Error fetching user data: $e');
    }
  }

  void _showUserInfoBottomSheet(
    BuildContext context,
    Map<String, dynamic> userData,
    String userId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              UserDetailsBottomSheet(userData: userData, userId: userId),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuIcon(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 85.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                color: Color(0xFFF9F5FE),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, size: 24.r, color: Colors.teal)),
            ),
            8.verticalSpace,
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoonTag() {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: ShapeDecoration(
        color: Color(0xFFF80B1B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      ),
      child: Text(
        'soon',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.sp,
          fontFamily: 'Kumbh Sans',
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
