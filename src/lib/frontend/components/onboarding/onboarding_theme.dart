import 'package:flutter/cupertino.dart';

/// Shared color tokens for the dev-style onboarding screens. Kept separate
/// from `core/theme.dart` for now so the rest of the app's Material theme
/// stays untouched while we port screens one at a time.
class OnboardingColors {
  OnboardingColors._();

  static const primary = Color(0xFF234A67);
  static const selectedBg = Color(0xFFE8F4F8);
  static const ink = Color(0xFF1C1C1C);
  static const sub = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const bgScroll = Color(0xFFFAFAFA);
  static const placeholder = Color(0xFFD1D5DB);
}
