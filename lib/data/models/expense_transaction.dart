// lib/data/models/expense_transaction.dart
// Core domain model representing a single expense record.

import '../../core/constants/expense_categories.dart';

class ExpenseTransaction {
  final String id;
  final double amount;
  final DateTime date;
  final String merchantName;
  final ExpenseCategory category;

  /// Path to the thumbnail image stored in the app's documents directory.
  /// May be null if no image was captured (manual entry).
  final String? imagePath;

  final DateTime createdAt;

  const ExpenseTransaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.merchantName,
    required this.category,
    this.imagePath,
    required this.createdAt,
  });

  /// Converts this model to a map for sqflite insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'merchant_name': merchantName,
      'category': category.dbValue,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Constructs an [ExpenseTransaction] from a sqflite row map.
  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      merchantName: map['merchant_name'] as String,
      category: ExpenseCategoryExtension.fromDbValue(map['category'] as String),
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Returns a copy with specified fields replaced.
  ExpenseTransaction copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? merchantName,
    ExpenseCategory? category,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ExpenseTransaction(id: $id, amount: $amount, merchant: $merchantName)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
