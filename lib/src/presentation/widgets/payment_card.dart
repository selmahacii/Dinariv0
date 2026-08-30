import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentCard extends StatelessWidget {
  final Widget child;
  final String label;
  final bool hasPromoTag;

  const PaymentCard({
    super.key,
    required this.child,
    required this.label,
    required this.hasPromoTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      margin: REdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Card content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Center(child: child)),
                SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Color(0xFF01796F),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Promo tag
          if (hasPromoTag)
            Positioned(
              left: 4.r,
              top: 16.r,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: Container(
                  padding: REdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Text(
                    'SOON',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Note: For this widget to work properly, you'll need to add the following 
// to your pubspec.yaml under the assets section:
//
// assets:
//   - assets/moov_logo.png
//   - assets/telecel_logo.png
//   - assets/orange_logo.png
//   - assets/cib_edahabia_logo.png
//   - assets/recharge_card.png