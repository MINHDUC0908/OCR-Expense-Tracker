// lib/features/ocr/ocr_service.dart
// ML Kit Text Recognition wrapper — performs on-device OCR on an image file.

import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../data/models/parsed_receipt.dart';
import 'receipt_parser.dart';

/// Orchestrates OCR processing: ML Kit recognition → ReceiptParser extraction.
class OcrService {
  final TextRecognizer _recognizer;
  final ReceiptParser _parser;

  OcrService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin),
        _parser = ReceiptParser();

  /// Processes the image at [imagePath] and returns a [ParsedReceipt].
  ///
  /// Throws [OcrException] if recognition fails.
  Future<ParsedReceipt> processImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw OcrException('Image file not found: $imagePath');
    }

    final inputImage = InputImage.fromFile(file);

    try {
      final recognized = await _recognizer.processImage(inputImage);
      final rawText = _buildRawText(recognized);

      if (rawText.trim().isEmpty) {
        return ParsedReceipt(
          rawText: '',
          confidence: 0.0,
        );
      }

      return _parser.parse(rawText);
    } catch (e) {
      throw OcrException('Text recognition failed: $e');
    }
  }

  /// Concatenates all recognized text blocks into a single string,
  /// preserving line breaks for the parser.
  String _buildRawText(RecognizedText recognized) {
    final buffer = StringBuffer();
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        buffer.writeln(line.text);
      }
      buffer.writeln(); // blank line between blocks
    }
    return buffer.toString();
  }

  /// Releases ML Kit resources. Must be called when the service is no longer needed.
  Future<void> dispose() async {
    await _recognizer.close();
  }
}

/// Thrown when OCR processing encounters an unrecoverable error.
class OcrException implements Exception {
  final String message;
  const OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}
