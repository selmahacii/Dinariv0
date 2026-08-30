import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserQRCodeBottomSheet extends StatelessWidget {
  final String userId;
  final String userName;

  const UserQRCodeBottomSheet({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 40.r,
            height: 4.r,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
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
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
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
              data: 'users/$userId',
              version: QrVersions.auto,
              size: 200.r,
              embeddedImage: const AssetImage('assets/app_icon.png'),
              embeddedImageStyle: QrEmbeddedImageStyle(size: Size(40.r, 40.r)),
            ),
          ),

          16.verticalSpace,

          Text(
            userName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),

          8.verticalSpace,

          Text(
            'ID: $userId',
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),

          24.verticalSpace,

          16.verticalSpace,
        ],
      ),
    );
  }
}
