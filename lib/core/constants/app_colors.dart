import 'package:flutter/material.dart';

/// Luxury Fintech Color Palette - Premium Design System
/// Inspired by Flip, Jenius, Bank Jago
class AppColors {
  // ═══════════════════════════════════════════════════════════
  // PRIMARY PALETTE - Deep Ocean Blue
  // ═══════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF0A2540);       // Navy deep - main brand color
  static const Color primaryLight = Color(0xFF1E3A5F);  // Navy medium - hover states
  static const Color primaryAccent = Color(0xFF00D4AA); // Teal accent - CTAs, highlights
  static const Color onPrimary = Color(0xFFFFFFFF);     // White text on primary
  
  // Primary Variants for Material 3
  static const Color primaryContainer = Color(0xFF1E3A5F);
  static const Color onPrimaryContainer = Color(0xFFE8F4FF);
  static const Color primaryFixed = Color(0xFFDBE8F5);
  static const Color primaryFixedDim = Color(0xFFB4D4E8);
  static const Color onPrimaryFixed = Color(0xFF0A1F35);
  static const Color onPrimaryFixedVariant = Color(0xFF0A2540);
  
  // ═══════════════════════════════════════════════════════════
  // SECONDARY PALETTE - Warm Amber
  // ═══════════════════════════════════════════════════════════
  static const Color secondary = Color(0xFFF59E0B);     // Amber - warnings, highlights
  static const Color onSecondary = Color(0xFF0F172A);   // Dark text on secondary
  static const Color secondaryContainer = Color(0xFFFDE68A);
  static const Color onSecondaryContainer = Color(0xFF78350F);
  static const Color secondaryFixed = Color(0xFFFEF3C7);
  static const Color secondaryFixedDim = Color(0xFFFCD34D);
  static const Color onSecondaryFixed = Color(0xFF451A03);
  static const Color onSecondaryFixedVariant = Color(0xFF92400E);
  
  // ═══════════════════════════════════════════════════════════
  // TERTIARY PALETTE - Cool Cyan
  // ═══════════════════════════════════════════════════════════
  static const Color tertiary = Color(0xFF06B6D4);      // Cyan - info, accents
  static const Color onTertiary = Color(0xFF0F172A);
  static const Color tertiaryContainer = Color(0xFF67E8F9);
  static const Color onTertiaryContainer = Color(0xFF164E63);
  static const Color tertiaryFixed = Color(0xFFECFEFF);
  static const Color tertiaryFixedDim = Color(0xFF22D3EE);
  static const Color onTertiaryFixed = Color(0xFF083344);
  static const Color onTertiaryFixedVariant = Color(0xFF0E7490);
  
  // ═══════════════════════════════════════════════════════════
  // ERROR PALETTE - Refined Red
  // ═══════════════════════════════════════════════════════════
  static const Color error = Color(0xFFEF4444);         // Red - errors, danger
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);
  
  // ═══════════════════════════════════════════════════════════
  // SUCCESS PALETTE - Emerald Green
  // ═══════════════════════════════════════════════════════════
  static const Color success = Color(0xFF10B981);       // Emerald - success, income
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccessContainer = Color(0xFF064E3B);
  
  // ═══════════════════════════════════════════════════════════
  // NEUTRAL PALETTE - Clean Slate Gray Series
  // ═══════════════════════════════════════════════════════════
  static const Color background = Color(0xFFF8FAFC);    // Main app background
  static const Color onBackground = Color(0xFF0F172A);  // Primary text color
  static const Color surface = Color(0xFFFFFFFF);       // Card backgrounds
  static const Color onSurface = Color(0xFF0F172A);     // Text on surfaces
  
  // Surface variants for depth
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color surfaceInverse = Color(0xFF1E293B);
  static const Color onSurfaceInverse = Color(0xFFF8FAFC);
  
  // Outline & Borders
  static const Color outline = Color(0xFF94A3B8);       // Default borders
  static const Color outlineVariant = Color(0xFFCBD5E1); // Subtle borders
  
  // ═══════════════════════════════════════════════════════════
  // SURFACE CONTAINERS - Layered Depth System
  // ═══════════════════════════════════════════════════════════
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);    // Topmost cards
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);       // Slight elevation
  static const Color surfaceContainer = Color(0xFFF1F5F9);          // Default level
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);      // Raised sections
  static const Color surfaceContainerHighest = Color(0xFFCBD5E1);   // Highest elevation
  
  // ═══════════════════════════════════════════════════════════
  // TEXT PALETTE - High Contrast System
  // ═══════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF0F172A);     // Almost black - main text
  static const Color textSecondary = Color(0xFF475569);   // Medium gray - subtitles
  static const Color textTertiary = Color(0xFF94A3B8);    // Light gray - hints
  static const Color textDisabled = Color(0xFFCBD5E1);    // Disabled states
  
  // ═══════════════════════════════════════════════════════════
  // INPUT FIELDS - Clean White with Black Text
  // ═══════════════════════════════════════════════════════════
  static const Color inputBackground = Color(0xFFFFFFFF);     // Pure white background
  static const Color inputText = Color(0xFF0F172A);           // Black text (CRITICAL FIX)
  static const Color inputHint = Color(0xFF94A3B8);           // Gray hints
  static const Color inputBorder = Color(0xFFE2E8F0);         // Light border
  static const Color inputBorderFocused = Color(0xFF0A2540);  // Primary on focus
  
  // ═══════════════════════════════════════════════════════════
  // GRADIENTS - Premium Feel
  // ═══════════════════════════════════════════════════════════
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2540), Color(0xFF1E3A5F), Color(0xFF00D4AA)],
    stops: [0.0, 0.6, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A5F), Color(0xFF0A2540)],
  );
  
  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
  
  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );
}
