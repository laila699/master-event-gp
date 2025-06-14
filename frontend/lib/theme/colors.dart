// lib/theme/app_colors.dart

import 'package:flutter/material.dart';

/// 2030-style neon pink⇆purple⇆white palette
class AppColors {
  /// Login & header gradient start (neon magenta)
  static const gradientStart = Color(0xFFD81B60);

  /// Login & header gradient end (deep purple)
  static const gradientEnd = Color(0xFF8E24AA);

  /// Background “canvas” (pure black)
  static const background = Color(0xFF000000);

  /// Glass card/frosted layer (5% white)
  static const glass = Color.fromRGBO(255, 255, 255, 0.05);

  /// Blur overlay (20% black)
  static const overlay = Color.fromRGBO(0, 0, 0, 0.20);

  /// Primary button/text color on neon backgrounds
  static const textOnNeon = Colors.white;

  /// Secondary text (for hints, subtitles)
  static const textSecondary = Colors.white70;

  /// Field fill on glass (10% white)
  static const fieldFill = Color.fromRGBO(255, 255, 255, 0.10);

  /// Border color for focused fields (use pure gradientStart)
  static const fieldBorder = gradientStart;

  /// Error text / danger
  static const error = Color(0xFFEF5350);
}
