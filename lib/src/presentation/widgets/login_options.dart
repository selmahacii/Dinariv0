import 'package:dinari/src/core/utils/constants/app_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class AuthOptions extends StatelessWidget {
  const AuthOptions({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
  });
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Login Button
        Container(
          width: double.infinity,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700), // Yellow color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child:
                isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 40),

        // "Or connect with" section
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: Colors.white,
                thickness: 1,
                indent: 20,
                endIndent: 10,
              ),
            ),
            Text(
              'Ou connectez-vous avec',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
            const Expanded(
              child: Divider(
                color: Colors.white,
                thickness: 1,
                indent: 10,
                endIndent: 20,
              ),
            ),
          ],
        ),

        30.verticalSpace,

        // Social login options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              onPressed: () {},
              child: Image(
                image: Svg(AppSvg.instance.google),
                height: 25.r,
                fit: BoxFit.contain,
              ),
            ),
            _buildSocialButton(
              onPressed: () {},
              child: Icon(Icons.facebook, color: Colors.blue, size: 30.r),
            ),
            _buildSocialButton(
              onPressed: () {},
              child: Icon(Icons.phone_android, color: Colors.black, size: 30.r),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Container(
      width: 100,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Center(child: child),
      ),
    );
  }
}
