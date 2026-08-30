import 'package:flutter/material.dart';

class GradiantWidget extends StatelessWidget {
  const GradiantWidget({super.key, required this.widget});
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFDCE26), // Yellow
            Color(0xFF007373), // Teal
            Color(0xFF01204D), // Dark Blue
          ],
          // transform: GradientRotation(120),
        ),
      ),
      child: widget,
    );
  }
}
