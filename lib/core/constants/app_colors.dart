// lib/core/constants/app_colors.dart
// Centralized color palette — dark-mode first design.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Background ---
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceVariant = Color(0xFF21262D);
  static const Color surfaceElevated = Color(0xFF30363D);

  // --- Primary accent (teal) ---
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00A884);
  static const Color primaryContainer = Color(0xFF003D30);

  // --- Text ---
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textDisabled = Color(0xFF484F58);

  // --- Semantic ---
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // --- Category colors (used in charts) ---
  static const Color catFood = Color(0xFFFF6B6B);
  static const Color catStudy = Color(0xFF4ECDC4);
  static const Color catTravel = Color(0xFF45B7D1);
  static const Color catGear = Color(0xFFFFD93D);
  static const Color catEntertainment = Color(0xFFAA96DA);

  // --- Divider / border ---
  static const Color divider = Color(0xFF30363D);
  static const Color border = Color(0xFF444C56);
}
