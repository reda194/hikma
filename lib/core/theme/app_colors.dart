import 'package:flutter/material.dart';

/// App color constants
class AppColors {
  AppColors._();

  // Primary colors from PRD
  static const Color primary = Color(0xFF1B4F72); // Deep blue
  static const Color primaryLight = Color(0xFF117A65); // Green accent
  static const Color background = Color(0xFFF8F9FA); // Light background
  static const Color text = Color(0xFF2C3E50); // Dark text
  static const Color surface = Color(0xFFEAF2F8); // Light blue card

  // UI colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Bookmark/favorite
  static const Color favorite = Color(0xFFFFD700); // Gold
  static const Color favoriteBorder = Color(0xFFB8860B);

  // Status colors
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);

  // Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
}
