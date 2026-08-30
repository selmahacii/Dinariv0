import 'package:dinari/src/core/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  ThemeConfig._();
  static final instance = ThemeConfig._();

  ThemeData lightTheme = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppColors.instance.primaryColor,
      secondary: AppColors.instance.secondaryColor,
      surface: AppColors.instance.surfaceColor,
    ),
    textTheme: GoogleFonts.kumbhSansTextTheme(),
    useMaterial3: true,
  );
}
