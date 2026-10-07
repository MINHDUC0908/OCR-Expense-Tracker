// lib/data/models/parsed_receipt.dart
// Kết quả nhận dạng văn bản OCR và trích xuất regex từ hóa đơn.

class ParsedReceipt {
  final double? amount;
  final DateTime? date;
  final String? merchantName;
  final String rawText;
  final double confidence;
  final int processingTimeMs;

  const ParsedReceipt({
    this.amount,
    this.date,
    this.merchantName,
    required this.rawText,
    required this.confidence,
    this.processingTimeMs = 0,
  });

  ParsedReceipt copyWith({
    double? amount,
    DateTime? date,
    String? merchantName,
    String? rawText,
    double? confidence,
    int? processingTimeMs,
  }) {
    return ParsedReceipt(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      merchantName: merchantName ?? this.merchantName,
      rawText: rawText ?? this.rawText,
      confidence: confidence ?? this.confidence,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
    );
  }

  @override
  String toString() {
    return 'ParsedReceipt('
        'amount: $amount, '
        'date: $date, '
        'merchant: $merchantName, '
        'confidence: ${(confidence * 100).toStringAsFixed(0)}%, '
        'time: ${processingTimeMs}ms)';
  }
}
