
import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - Vibrant Purple to Pink Gradient Theme
  static const Color primary = Color(0xFF6C63FF); // Vibrant Indigo
  static const Color primaryDark = Color(0xFF4F46E5); // Deep Indigo
  static const Color primaryLight = Color(0xFF8B85FF); // Light Indigo
  
  // Accent Colors - Energetic Gradient Palette
  static const Color accent = Color(0xFFFF6B9D); // Vibrant Pink
  static const Color accentOrange = Color(0xFFFF8A5B); // Coral Orange
  static const Color accentGold = Color(0xFFFFC542); // Golden Yellow
  static const Color accentTeal = Color(0xFF00D9C0); // Electric Teal
  
  // Background & Surface - Modern Dark Mode Feel
  static const Color background = Color(0xFFF8F9FE); // Soft Lavender White
  static const Color backgroundDark = Color(0xFFEEF0FB); // Light Periwinkle
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFFDFDFF); // Pure White with hint of blue
  
  // Semantic Colors
  static const Color success = Color(0xFF00D9A3); // Mint Green
  static const Color warning = Color(0xFFFFB84D); // Amber
  static const Color error = Color(0xFFFF5252); // Bright Red
  static const Color info = Color(0xFF64B5F6); // Sky Blue
  
  // Text Colors - High Contrast & Readable
  static const Color textPrimary = Color(0xFF1A1A2E); // Deep Navy
  static const Color textSecondary = Color(0xFF6B7280); // Cool Gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Light Gray
  static const Color textHint = Color(0xFFD1D5DB); // Very Light Gray
  static const Color textOnDark = Color(0xFFFFFBFF); // Off White
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5B52FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF8A5B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF8A5B), Color(0xFFFFC542)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D9C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Additional UI Colors
  static const Color divider = Color(0xFFE5E7EB);
  static const Color cardShadow = Color(0x0F6C63FF); // Subtle purple shadow
  static const Color cardShadowLight = Color(0x08000000);
  static const Color shimmerBase = Color(0xFFEEF0FB);
  static const Color shimmerHighlight = Color(0xFFF8F9FE);
  
  // Category Colors - Vibrant & Distinctive
  static const Color categoryTech = Color(0xFF6C63FF);
  static const Color categoryBusiness = Color(0xFF00D9C0);
  static const Color categorySports = Color(0xFFFF6B9D);
  static const Color categoryHealth = Color(0xFF00D9A3);
  static const Color categoryEntertainment = Color(0xFFFF8A5B);
  static const Color categoryScience = Color(0xFF64B5F6);
  
  // Legacy support
  static const Color secondary = accentTeal;
  static const Color onPrimary = textOnDark;
  static const Color onSecondary = textPrimary;
  static const Color onBackground = textPrimary;
  static const Color onSurface = textPrimary;
  static const Color onError = textOnDark;
}

extension ColorValuesCompat on Color {
  Color withValues({
    double? alpha,
    double? red,
    double? green,
    double? blue,
  }) {
    if (alpha == null && red == null && green == null && blue == null) {
      return this;
    }

  final int argb = toARGB32();
    final int currentRed = (argb >> 16) & 0xFF;
    final int currentGreen = (argb >> 8) & 0xFF;
    final int currentBlue = argb & 0xFF;
    final double currentAlphaUnit = ((argb >> 24) & 0xFF) / 255.0;

    final int r = red != null ? _componentFromUnit(red) : currentRed;
    final int g = green != null ? _componentFromUnit(green) : currentGreen;
    final int b = blue != null ? _componentFromUnit(blue) : currentBlue;
    final double aUnit = alpha != null ? _clampUnit(alpha) : currentAlphaUnit;

    return Color.fromARGB(
      (aUnit * 255).round(),
      r,
      g,
      b,
    );
  }
}

double _clampUnit(double value) {
  if (value.isNaN) {
    return 0;
  }
  if (value < 0) {
    return 0;
  }
  if (value > 1) {
    return 1;
  }
  return value;
}

int _componentFromUnit(double value) {
  final double safe = _clampUnit(value);
  return (safe * 255).round();
}