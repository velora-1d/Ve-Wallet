import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF004AC6);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimaryFixedVariant = Color(0xFF003EA8);
  static const Color secondary = Color(0xFF9D4300);
  static const Color secondaryContainer = Color(0xFFFD761A);
  
  // Neutral Colors
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color onBackground = Color(0xFF131B2E);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color outline = Color(0xFF737686);
  
  // Functional Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF4CAF50); // Added for common use
  
  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      onPrimaryFixedVariant,
      primaryContainer,
    ],
  );
}
