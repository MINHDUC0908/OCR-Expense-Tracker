// lib/core/utils/currency_formatter.dart
// Utility for formatting monetary amounts in Vietnamese Dong (VND).

import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormatter = NumberFormat('#,###', 'vi_VN');

  /// Formats [amount] as Vietnamese dong, e.g. 150,000 đ
  static String formatVnd(double amount) {
    return '${_vndFormatter.format(amount.toInt())} đ';
  }

  /// Formats [amount] with compact notation for large values, e.g. 1.5M đ
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M đ';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K đ';
    }
    return formatVnd(amount);
  }
}
