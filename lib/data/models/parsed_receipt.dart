// lib/data/models/parsed_receipt.dart
// Represents the result of OCR + heuristic parsing of a receipt image.

class ParsedReceipt {
  /// The parsed monetary amount in VND. Null if parsing failed.
  final double? amount;

  /// The parsed transaction date. Null if parsing failed.
  final DateTime? date;

  /// The parsed merchant name. Null if parsing failed.
  final String? merchantName;

  /// The raw OCR text returned by ML Kit.
  final String rawText;

  /// Confidence score from 0.0 (nothing parsed) to 1.0 (all fields parsed).
  final double confidence;

  const ParsedReceipt({
    this.amount,
    this.date,
    this.merchantName,
    required this.rawText,
    required this.confidence,
  });

  /// Returns a copy of this receipt with the given fields overridden.
  ParsedReceipt copyWith({
    double? amount,
    DateTime? date,
    String? merchantName,
    String? rawText,
    double? confidence,
  }) {
    return ParsedReceipt(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      merchantName: merchantName ?? this.merchantName,
      rawText: rawText ?? this.rawText,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  String toString() {
    return 'ParsedReceipt('
        'amount: $amount, '
        'date: $date, '
        'merchant: $merchantName, '
        'confidence: ${(confidence * 100).toStringAsFixed(0)}%)';
  }
}
