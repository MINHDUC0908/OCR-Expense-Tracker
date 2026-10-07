// lib/core/constants/expense_categories.dart
// Fixed expense categories with associated metadata.

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// The five fixed expense categories supported by the app.
enum ExpenseCategory {
  food,
  study,
  travel,
  gear,
  entertainment,
}

/// Extension that provides display metadata for each [ExpenseCategory].
extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Thực phẩm';
      case ExpenseCategory.study:
        return 'Học tập';
      case ExpenseCategory.travel:
        return 'Du lịch';
      case ExpenseCategory.gear:
        return 'Thiết bị';
      case ExpenseCategory.entertainment:
        return 'Giải trí';
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.food:
        return '🍔';
      case ExpenseCategory.study:
        return '📚';
      case ExpenseCategory.travel:
        return '✈️';
      case ExpenseCategory.gear:
        return '🔧';
      case ExpenseCategory.entertainment:
        return '🎬';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.study:
        return Icons.menu_book_rounded;
      case ExpenseCategory.travel:
        return Icons.flight_rounded;
      case ExpenseCategory.gear:
        return Icons.build_rounded;
      case ExpenseCategory.entertainment:
        return Icons.movie_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.catFood;
      case ExpenseCategory.study:
        return AppColors.catStudy;
      case ExpenseCategory.travel:
        return AppColors.catTravel;
      case ExpenseCategory.gear:
        return AppColors.catGear;
      case ExpenseCategory.entertainment:
        return AppColors.catEntertainment;
    }
  }

  /// Stores as a plain string in the database.
  String get dbValue => name;

  /// Parses a database string back to enum.
  static ExpenseCategory fromDbValue(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpenseCategory.food,
    );
  }
}
