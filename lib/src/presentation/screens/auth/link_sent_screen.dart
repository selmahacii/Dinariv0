import 'package:dinari/src/core/utils/constants/app_colors.dart';
import 'package:dinari/src/core/utils/constants/app_svg.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class LinkSentScreen extends StatelessWidget {
  const LinkSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: AppColors.instance.surfaceColor,
          size: 30.r,
        ),
      ),
      body: GradiantWidget(
        widget: SizedBox(
          width: 327.w,
          height: 516.h,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  width: 103.r,
                  height: 103.r,
                  fit: BoxFit.contain, image: Svg(AppSvg.instance.check)),
                32.verticalSpace,
                  Text(
                    'Lien envoyé avec succès',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  12.verticalSpace,
                  Text(
                    'Entrez votre email et vous trouverez un lien',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  16.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
