import 'package:flutter/material.dart';

/// Lokahi brand palette + screen neutrals + semantic colors. Source of truth
/// for every color in the app — screens should not introduce ad-hoc hex.
class AppColors {
  AppColors._();

  // Brand
  static const darkTeal = Color(0xFF234A67); // primary
  static const mediumTeal = Color(0xFF1C425B); // hover
  static const deepNavy = Color(0xFF113687); // accent
  static const skyBlue = Color(0xFF7ABEE1); // secondary
  static const tealTint = Color(0xFFE8F4F8); // muted background
  static const offWhite = Color(0xFFFDFCFA);

  // Screen neutrals
  static const screenBg = Color(0xFFFAFAFA);
  static const cardBg = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const borderSubtle = Color(0xFFF3F4F6);
  static const muted = Color(0xFF6B7280);
  static const inkBlack = Color(0xFF1C1C1C);

  // Semantic
  static const success = Color(0xFF15803D);
  static const successBg = Color(0xFFECFDF5);
  static const warning = Color(0xFFB45309);
  static const warningBg = Color(0xFFFEF3C7);
  static const danger = Color(0xFFDC2626);
  static const dangerBg = Color(0xFFFEF2F2);
}

/// Border radii from the handoff design tokens.
class AppRadii {
  AppRadii._();
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;
}

/// Type scale from the handoff design tokens. Reference, not a closed set —
/// screens may compose `TextStyle.copyWith(...)` for per-instance tweaks.
class AppText {
  AppText._();

  static const String fontFamily = 'Inter';

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
    height: 1.25,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inkBlack,
    height: 1.5,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.5,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
    letterSpacing: 1.2,
  );
}

/// Material theme used by [MaterialApp.router] at the app root.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: AppText.fontFamily,
    scaffoldBackgroundColor: AppColors.screenBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.darkTeal,
      onPrimary: Colors.white,
      secondary: AppColors.skyBlue,
      onSecondary: AppColors.inkBlack,
      surface: AppColors.cardBg,
      onSurface: AppColors.inkBlack,
      error: AppColors.danger,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: AppText.displayLg,
      headlineMedium: AppText.displayMd,
      titleLarge: AppText.title,
      bodyMedium: AppText.body,
      bodySmall: AppText.caption,
      labelSmall: AppText.eyebrow,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.darkTeal, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: AppText.bodyMuted,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        textStyle: const TextStyle(
          fontFamily: AppText.fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkTeal,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        textStyle: const TextStyle(
          fontFamily: AppText.fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkTeal,
        textStyle: const TextStyle(
          fontFamily: AppText.fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
  );
}
