// lib/features/ocr/receipt_parser.dart
// Heuristic regex-based parser that extracts structured fields from raw OCR text.

import '../../data/models/parsed_receipt.dart';

/// Extracts [ParsedReceipt] fields from raw OCR text using regex heuristics.
///
/// Supported formats:
/// - Amount: "150,000 VND", "150.000 đ", "150000đ", "150.000d", "1,500,000"
/// - Date:   "DD/MM/YYYY", "DD-MM-YYYY", "15 Sep 2026", "Sep 15, 2026"
/// - Merchant: first ALL_CAPS line near the top, excluding blacklisted keywords
class ReceiptParser {
  // ── Amount patterns ──────────────────────────────────────────────────────

  /// Matches VND amounts with thousands separators (. or ,) and optional suffix.
  /// Examples: 150,000 VND | 150.000 đ | 150000đ | 1,500,000đ | 150.000d
  static final RegExp _amountPattern = RegExp(
    r'(\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?|\d+(?:[.,]\d{2})?)'
    r'\s*(?:VND|vnđ|vnD|vnd|đ|d\b)',
    caseSensitive: false,
  );

  /// Fallback: lines containing TOTAL / TỔNG CỘNG / THÀNH TIỀN followed by a number.
  static final RegExp _totalLabelPattern = RegExp(
    r'(?:total|tổng\s*cộng|tổng\s*tiền|thành\s*tiền|grand\s*total|cộng\s*tiền)'
    r'[:\s*]*'
    r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
    caseSensitive: false,
  );

  // ── Date patterns ─────────────────────────────────────────────────────────

  /// DD/MM/YYYY or DD-MM-YYYY
  static final RegExp _dateNumericPattern = RegExp(
    r'\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})\b',
  );

  /// "15 Sep 2026" or "15 September 2026"
  static final RegExp _dateWordPattern = RegExp(
    r'\b(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec'
    r'|January|February|March|April|June|July|August|September|October|November|December'
    r'|Th\d|tháng\s*\d+)\s+(\d{4})\b',
    caseSensitive: false,
  );

  // ── Merchant blacklist ────────────────────────────────────────────────────

  static const List<String> _blacklist = [
    'HÓA ĐƠN',
    'HOA DON',
    'RECEIPT',
    'INVOICE',
    'BILL',
    'DATE',
    'NGÀY',
    'TOTAL',
    'TỔNG',
    'AMOUNT',
    'SỐ TIỀN',
    'CASH',
    'TIỀN MẶT',
    'THANK YOU',
    'XIN CẢM ƠN',
    'PHONE',
    'ADDRESS',
    'ĐỊA CHỈ',
    'TEL',
    'FAX',
    'WEBSITE',
    'HTTP',
    'WWW',
    'VAT',
    'MST',
    'MSSV',
    'ORDER',
    'TABLE',
    'BÀN',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────────

  /// Parses [rawText] (from ML Kit OCR) and returns a [ParsedReceipt].
  ParsedReceipt parse(String rawText) {
    final amount = _extractAmount(rawText);
    final date = _extractDate(rawText);
    final merchantName = _extractMerchant(rawText);

    // Confidence: how many of the 3 fields were successfully extracted.
    final fieldsFound = [amount, date, merchantName]
        .where((f) => f != null)
        .length;
    final confidence = fieldsFound / 3.0;

    return ParsedReceipt(
      amount: amount,
      date: date,
      merchantName: merchantName,
      rawText: rawText,
      confidence: confidence,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Extracts the highest VND amount found in [text].
  ///
  /// Strategy: prefer amounts on "total" label lines; otherwise take the
  /// largest numeric value with a VND suffix.
  double? _extractAmount(String text) {
    // 1. Try "TOTAL" labelled line first.
    final totalMatch = _totalLabelPattern.firstMatch(text);
    if (totalMatch != null) {
      return _parseVndNumber(totalMatch.group(1)!);
    }

    // 2. Find all VND-suffixed amounts and return the largest.
    final matches = _amountPattern.allMatches(text);
    if (matches.isEmpty) return null;

    double maxAmount = 0;
    for (final m in matches) {
      final val = _parseVndNumber(m.group(1)!);
      if (val != null && val > maxAmount) {
        maxAmount = val;
      }
    }
    return maxAmount > 0 ? maxAmount : null;
  }

  /// Converts a formatted number string to [double].
  /// Handles both VN style (1.000,50) and international style (1,000.50).
  double? _parseVndNumber(String raw) {
    try {
      // Detect format by last separator.
      final cleaned = raw.trim();

      // Count dots and commas.
      final dots = '.'.allMatches(cleaned).length;
      final commas = ','.allMatches(cleaned).length;

      String normalized;
      if (dots > 0 && commas == 0) {
        // "150.000" — Vietnamese thousands dot → strip dots.
        normalized = cleaned.replaceAll('.', '');
      } else if (commas > 0 && dots == 0) {
        // "150,000" — international thousands comma → strip commas.
        normalized = cleaned.replaceAll(',', '');
      } else if (dots > 0 && commas > 0) {
        // Mixed: last separator is decimal.
        final lastDot = cleaned.lastIndexOf('.');
        final lastComma = cleaned.lastIndexOf(',');
        if (lastDot > lastComma) {
          // "1,500.50" → international decimal
          normalized = cleaned.replaceAll(',', '');
        } else {
          // "1.500,50" → VN decimal
          normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
        }
      } else {
        normalized = cleaned;
      }
      return double.parse(normalized);
    } catch (_) {
      return null;
    }
  }

  /// Extracts the first valid date from [text].
  DateTime? _extractDate(String text) {
    // Try DD/MM/YYYY or DD-MM-YYYY.
    final numMatch = _dateNumericPattern.firstMatch(text);
    if (numMatch != null) {
      final day = int.parse(numMatch.group(1)!);
      final month = int.parse(numMatch.group(2)!);
      final year = int.parse(numMatch.group(3)!);
      if (_isValidDate(year, month, day)) {
        return DateTime(year, month, day);
      }
    }

    // Try word-month date.
    final wordMatch = _dateWordPattern.firstMatch(text);
    if (wordMatch != null) {
      final day = int.parse(wordMatch.group(1)!);
      final monthStr = wordMatch.group(2)!;
      final year = int.parse(wordMatch.group(3)!);
      final month = _parseMonthName(monthStr);
      if (month != null && _isValidDate(year, month, day)) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  bool _isValidDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    if (year < 2000 || year > 2100) return false;
    return true;
  }

  int? _parseMonthName(String name) {
    const months = {
      'jan': 1, 'january': 1,
      'feb': 2, 'february': 2,
      'mar': 3, 'march': 3,
      'apr': 4, 'april': 4,
      'may': 5,
      'jun': 6, 'june': 6,
      'jul': 7, 'july': 7,
      'aug': 8, 'august': 8,
      'sep': 9, 'september': 9,
      'oct': 10, 'october': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };
    // Handle Vietnamese "tháng 9"
    final thangMatch = RegExp(r'tháng\s*(\d+)', caseSensitive: false)
        .firstMatch(name.toLowerCase());
    if (thangMatch != null) {
      return int.tryParse(thangMatch.group(1)!);
    }
    return months[name.toLowerCase()];
  }

  /// Extracts the most likely merchant name from the first ~10 lines.
  String? _extractMerchant(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .take(10)
        .toList();

    for (final line in lines) {
      if (_isValidMerchantLine(line)) {
        // Normalize: title-case the result.
        return _normalizeMerchantName(line);
      }
    }

    // Fallback: return the first non-blacklisted, reasonably long line.
    for (final line in lines) {
      final upper = line.toUpperCase();
      final isBlacklisted = _blacklist.any((kw) => upper.contains(kw));
      if (!isBlacklisted && line.length >= 3 && line.length <= 60) {
        return _normalizeMerchantName(line);
      }
    }

    return null;
  }

  /// Returns true if [line] looks like a merchant name.
  bool _isValidMerchantLine(String line) {
    // Must be reasonably long (store names are ≥4 chars).
    if (line.length < 4 || line.length > 80) return false;

    final upper = line.toUpperCase();

    // Reject blacklisted keywords.
    if (_blacklist.any((kw) => upper.contains(kw))) return false;

    // Reject lines that look like amounts or dates.
    if (_amountPattern.hasMatch(line)) return false;
    if (_dateNumericPattern.hasMatch(line)) return false;

    // Reject purely numeric lines.
    if (RegExp(r'^\d+$').hasMatch(line)) return false;

    // Prefer ALL_CAPS or Title Case lines (typical for merchant headers).
    final isAllCaps = line == line.toUpperCase() && line.contains(RegExp(r'[A-ZÀ-Ỹ]'));
    final hasLetters = line.contains(RegExp(r'[a-zA-ZÀ-ỹ]'));

    return isAllCaps || hasLetters;
  }

  String _normalizeMerchantName(String line) {
    // Remove special characters at boundaries.
    var name = line
        .replaceAll(RegExp(r'^[\*\-\_\=\#\s]+'), '')
        .replaceAll(RegExp(r'[\*\-\_\=\#\s]+$'), '');

    // Trim excessive whitespace.
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

    return name;
  }
}
