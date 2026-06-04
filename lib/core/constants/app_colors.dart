import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color bg1 = Color(0xFF0A0E27);
  static const Color bg2 = Color(0xFF1B2250);
  static const Color bg3 = Color(0xFF141832);

  // Accents
  static const Color primary   = Color(0xFF4361EE);
  static const Color cyan      = Color(0xFF4CC9F0);
  static const Color violet    = Color(0xFF7209B7);
  static const Color pink      = Color(0xFFF72585);
  static const Color success   = Color(0xFF06D6A0);
  static const Color warning   = Color(0xFFFFB703);
  static const Color error     = Color(0xFFEF233C);

  // Card accent palette
  static const Color card1 = Color(0xFF4361EE);
  static const Color card2 = Color(0xFF4CC9F0);
  static const Color card3 = Color(0xFF7209B7);
  static const Color card4 = Color(0xFFF72585);

  // Glass
  static const Color glassWhite  = Color(0x14FFFFFF); // 8%
  static const Color glassBorder = Color(0x26FFFFFF); // 15%
  static const Color glassWhite2 = Color(0x20FFFFFF); // 12%

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D4);
  static const Color textHint      = Color(0xFF6B7A99);
  static const Color divider       = Color(0x1AFFFFFF);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bg1, bg2, bg3],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
  );

  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7209B7), Color(0xFFF72585)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CC9F0), Color(0xFF4361EE)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06D6A0), Color(0xFF4CC9F0)],
  );
}
