import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);
  static const Color onPrimaryFixedVariant = Color(0xFF003EA8);

  // Secondary
  static const Color secondary = Color(0xFF9D4300);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFD761A);
  static const Color onSecondaryContainer = Color(0xFF5C2400);
  static const Color secondaryFixed = Color(0xFFFFDBCA);
  static const Color secondaryFixedDim = Color(0xFFFFB690);
  static const Color onSecondaryFixed = Color(0xFF341100);
  static const Color onSecondaryFixedVariant = Color(0xFF783200);

  // Tertiary
  static const Color tertiary = Color(0xFF2053A0);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF3E6CBA);
  static const Color onTertiaryContainer = Color(0xFFECF0FF);
  static const Color tertiaryFixed = Color(0xFFD8E2FF);
  static const Color tertiaryFixedDim = Color(0xFFACC7FF);
  static const Color onTertiaryFixed = Color(0xFF001A41);
  static const Color onTertiaryFixedVariant = Color(0xFF044491);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Neutral
  static const Color background = Color(0xFFFAF8FF);
  static const Color onBackground = Color(0xFF131B2E);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color surfaceVariant = Color(0xFFDAE2FD);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  
  // Surface Containers
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);

  // Success (Added)
  static const Color success = Color(0xFF4CAF50);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      onPrimaryFixedVariant,
      primaryContainer,
    ],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A4F9C),
      primaryContainer,
    ],
  );
}
