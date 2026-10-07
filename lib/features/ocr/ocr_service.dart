import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../data/models/parsed_receipt.dart';
import 'receipt_parser.dart';

/// Dịch vụ xử lý OCR on-device với Google ML Kit + Regex heuristics.
class OcrService {
  final TextRecognizer _recognizer;
  final ReceiptParser _parser;

  OcrService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin),
        _parser = ReceiptParser();

  /// Xử lý ảnh tại [imagePath] và trả về [ParsedReceipt] với thời gian đo đạc (ms).
  Future<ParsedReceipt> processImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw OcrException('Không tìm thấy tệp ảnh: $imagePath');
    }

    final inputImage = InputImage.fromFile(file);

    try {
      final stopwatch = Stopwatch()..start();
      final recognized = await _recognizer.processImage(inputImage);
      final rawText = _buildRawText(recognized);
      final parsed = _parser.parse(rawText);
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;

      if (rawText.trim().isEmpty) {
        return ParsedReceipt(
          rawText: '',
          confidence: 0.0,
          processingTimeMs: elapsedMs,
        );
      }

      return parsed.copyWith(processingTimeMs: elapsedMs);
    } catch (e) {
      throw OcrException('Lỗi nhận dạng văn bản: $e');
    }
  }

  String _buildRawText(RecognizedText recognized) {
    final buffer = StringBuffer();
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        buffer.writeln(line.text);
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}

class OcrException implements Exception {
  final String message;
  const OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}
