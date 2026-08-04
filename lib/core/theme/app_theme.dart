import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cqaag_app/core/constants/index.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightOrange,
      colorScheme: ColorScheme.light(
        primary: AppColors.darkBrown,
        secondary: AppColors.grayOrange,
        surface: AppColors.white,
        error: Colors.redAccent,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkRed,
      ),
      textTheme: _textTheme,
    );
  }

  static ThemeData get darkTheme {
    // A separate dark theme or just an inverted version
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkRed,
      colorScheme: ColorScheme.dark(
        primary: AppColors.grayOrange,
        secondary: AppColors.deepGrayOrange,
        surface: AppColors.darkBrown,
        error: Colors.redAccent,
        onPrimary: AppColors.darkRed,
        onSecondary: AppColors.white,
        onSurface: AppColors.lightOrange,
      ),
      textTheme: _textTheme,
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      // Headings
      displayLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 32, color: AppColors.darkBrown),
      displayMedium: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.darkBrown),
      displaySmall: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.darkBrown),
      headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.darkBrown),

      // Body text
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: AppColors.darkRed),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkRed),
      bodySmall: GoogleFonts.poppins(fontSize: 12, color: AppColors.darkRed),

      // Button text etc
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.white),
    );
  }
}
