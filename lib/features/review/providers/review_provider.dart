import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/expense_categories.dart';
import '../../../data/models/expense_transaction.dart';
import '../../../data/models/parsed_receipt.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../ocr/ocr_service.dart';

/// Form state for editing parsed receipt before saving.
class ReviewState {
  final String imagePath;
  final bool isOcrLoading;
  final String? ocrError;
  final ParsedReceipt? parsedReceipt;

  final double amount;
  final DateTime date;
  final String merchantName;
  final ExpenseCategory category;
  final bool isSaving;

  const ReviewState({
    required this.imagePath,
    this.isOcrLoading = true,
    this.ocrError,
    this.parsedReceipt,
    this.amount = 0.0,
    required this.date,
    this.merchantName = '',
    this.category = ExpenseCategory.food,
    this.isSaving = false,
  });

  ReviewState copyWith({
    String? imagePath,
    bool? isOcrLoading,
    String? ocrError,
    ParsedReceipt? parsedReceipt,
    double? amount,
    DateTime? date,
    String? merchantName,
    ExpenseCategory? category,
    bool? isSaving,
  }) {
    return ReviewState(
      imagePath: imagePath ?? this.imagePath,
      isOcrLoading: isOcrLoading ?? this.isOcrLoading,
      ocrError: ocrError ?? this.ocrError,
      parsedReceipt: parsedReceipt ?? this.parsedReceipt,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Family notifier that takes an [imagePath] and runs OCR upon init.
class ReviewNotifier extends FamilyNotifier<ReviewState, String> {
  final OcrService _ocrService = OcrService();
  final TransactionRepository _repository = TransactionRepository();

  @override
  ReviewState build(String arg) {
    ref.onDispose(() {
      _ocrService.dispose();
    });

    // Run OCR asynchronously
    _runOcr(arg);

    return ReviewState(
      imagePath: arg,
      date: DateTime.now(),
    );
  }

  Future<void> _runOcr(String path) async {
    try {
      final parsed = await _ocrService.processImage(path);

      // Guess category from merchant or raw text if possible
      final guessedCat = _guessCategory(parsed.merchantName, parsed.rawText);

      state = state.copyWith(
        isOcrLoading: false,
        parsedReceipt: parsed,
        amount: parsed.amount ?? 0.0,
        date: parsed.date ?? DateTime.now(),
        merchantName: parsed.merchantName ?? 'Unknown Merchant',
        category: guessedCat,
      );
    } catch (e) {
      state = state.copyWith(
        isOcrLoading: false,
        ocrError: e.toString(),
      );
    }
  }

  void updateAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void updateMerchant(String merchant) {
    state = state.copyWith(merchantName: merchant);
  }

  void updateCategory(ExpenseCategory category) {
    state = state.copyWith(category: category);
  }

  /// Copies image to app document directory and saves transaction to SQLite.
  Future<bool> saveTransaction() async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true);

    try {
      String? savedImagePath;

      // Persist thumbnail / receipt image to app documents directory
      if (state.imagePath.isNotEmpty) {
        final originalFile = File(state.imagePath);
        if (await originalFile.exists()) {
          final docsDir = await getApplicationDocumentsDirectory();
          final receiptsDir = Directory(p.join(docsDir.path, 'receipts'));
          if (!await receiptsDir.exists()) {
            await receiptsDir.create(recursive: true);
          }

          final ext = p.extension(state.imagePath);
          final newFileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}$ext';
          final newFilePath = p.join(receiptsDir.path, newFileName);
          final savedFile = await originalFile.copy(newFilePath);
          savedImagePath = savedFile.path;
        }
      }

      final transaction = ExpenseTransaction(
        id: const Uuid().v4(),
        amount: state.amount,
        date: state.date,
        merchantName: state.merchantName.trim().isEmpty
            ? 'General Store'
            : state.merchantName.trim(),
        category: state.category,
        imagePath: savedImagePath,
        createdAt: DateTime.now(),
      );

      await _repository.insert(transaction);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, ocrError: 'Failed to save: $e');
      return false;
    }
  }

  ExpenseCategory _guessCategory(String? merchant, String rawText) {
    final combined = '${merchant ?? ''} $rawText'.toLowerCase();

    if (combined.contains(RegExp(r'coffee|cafe|cà phê|tea|trà|food|quán|nhà hàng|bánh|cơm|phở|bún|lẩu'))) {
      return ExpenseCategory.food;
    }
    if (combined.contains(RegExp(r'sách|vở|book|tập|giáo trình|pen|bút|photo|in ấn|học phí|study|course'))) {
      return ExpenseCategory.study;
    }
    if (combined.contains(RegExp(r'grab|be|xăng|petro|xe|bus|vé xe|taxi|vé máy bay|flight|travel|hotel'))) {
      return ExpenseCategory.travel;
    }
    if (combined.contains(RegExp(r'chuột|bàn phím|laptop|tai nghe|phone|case|gear|dây sạc|cáp|adapter|linh kiện'))) {
      return ExpenseCategory.gear;
    }
    if (combined.contains(RegExp(r'cgv|cinema|phim|game|karaoke|vé|billiards|bida|net|chill'))) {
      return ExpenseCategory.entertainment;
    }

    return ExpenseCategory.food;
  }
}

final reviewProvider =
    NotifierProvider.family<ReviewNotifier, ReviewState, String>(
  ReviewNotifier.new,
);
