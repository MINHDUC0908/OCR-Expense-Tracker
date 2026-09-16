// lib/core/constants/app_colors.dart
// Bảng màu tươi sáng — chủ đề nhiệt đới Việt Nam

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Nền ---
  static const Color background = Color(0xFFF5F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF1FB);
  static const Color surfaceElevated = Color(0xFFE3E8F8);

  // --- Màu chủ đạo: Cam san hô rực rỡ ---
  static const Color primary = Color(0xFFFF5A5F);
  static const Color primaryDark = Color(0xFFE0373C);
  static const Color primaryContainer = Color(0xFFFFE4E5);
  static const Color primaryLight = Color(0xFFFFECEC);

  // --- Màu phụ: Xanh biển nhiệt đới ---
  static const Color secondary = Color(0xFF00B4D8);
  static const Color secondaryContainer = Color(0xFFDDF4FA);

  // --- Màu nhấn: Vàng cam rực ---
  static const Color accent = Color(0xFFFFB347);
  static const Color accentContainer = Color(0xFFFFF3E0);

  // --- Màu thứ ba: Xanh lá mint ---
  static const Color tertiary = Color(0xFF06D6A0);
  static const Color tertiaryContainer = Color(0xFFDEFFF6);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1A1F3A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFB0B7C3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Semantic ---
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF5A5F);
  static const Color info = Color(0xFF00B4D8);

  // --- Màu danh mục (biểu đồ) ---
  static const Color catFood = Color(0xFFFF6B6B);
  static const Color catStudy = Color(0xFF4CC9F0);
  static const Color catTravel = Color(0xFF7B61FF);
  static const Color catGear = Color(0xFFFFB347);
  static const Color catEntertainment = Color(0xFFFF48B0);

  // --- Đường kẻ / viền ---
  static const Color divider = Color(0xFFE8EBF5);
  static const Color border = Color(0xFFD1D9F0);

  // --- Gradient chủ đạo ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5A5F), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFF5A5F), Color(0xFFFF8E53), Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF4361EE), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF4CC9F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
