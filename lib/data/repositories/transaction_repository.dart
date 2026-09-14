// lib/data/repositories/transaction_repository.dart
// CRUD operations and query methods for [ExpenseTransaction].

import 'package:sqflite/sqflite.dart';
import '../../core/constants/expense_categories.dart';
import '../models/expense_transaction.dart';
import 'database_helper.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // ─────────────── Write ───────────────

  /// Inserts a new [ExpenseTransaction] into the database.
  /// Throws [DatabaseException] on conflict.
  Future<void> insert(ExpenseTransaction tx) async {
    final db = await _db;
    await db.insert(
      DatabaseHelper.tableTransactions,
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing transaction by [id].
  Future<void> update(ExpenseTransaction tx) async {
    final db = await _db;
    await db.update(
      DatabaseHelper.tableTransactions,
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  /// Deletes a transaction by [id].
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(
      DatabaseHelper.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─────────────── Read ───────────────

  /// Returns all transactions ordered by date descending.
  Future<List<ExpenseTransaction>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      DatabaseHelper.tableTransactions,
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  /// Returns transactions filtered by [category].
  Future<List<ExpenseTransaction>> getByCategory(
      ExpenseCategory category) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseHelper.tableTransactions,
      where: 'category = ?',
      whereArgs: [category.dbValue],
      orderBy: 'date DESC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  /// Returns transactions within [start] and [end] dates (inclusive).
  Future<List<ExpenseTransaction>> getByDateRange(
      DateTime start, DateTime end) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseHelper.tableTransactions,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  /// Returns the total amount spent per category as a map.
  Future<Map<ExpenseCategory, double>> getTotalByCategory() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM ${DatabaseHelper.tableTransactions}
      GROUP BY category
    ''');

    final result = <ExpenseCategory, double>{};
    for (final row in rows) {
      final cat = ExpenseCategoryExtension.fromDbValue(row['category'] as String);
      result[cat] = (row['total'] as num).toDouble();
    }
    return result;
  }

  /// Returns the total amount spent per day for the last [days] days.
  Future<Map<DateTime, double>> getDailyTotals({int days = 7}) async {
    final db = await _db;
    final cutoff = DateTime.now().subtract(Duration(days: days - 1));
    final cutoffStr = cutoff.toIso8601String().substring(0, 10); // date only

    final rows = await db.rawQuery('''
      SELECT DATE(date) as day, SUM(amount) as total
      FROM ${DatabaseHelper.tableTransactions}
      WHERE DATE(date) >= ?
      GROUP BY DATE(date)
      ORDER BY day ASC
    ''', [cutoffStr]);

    final result = <DateTime, double>{};
    for (final row in rows) {
      final day = DateTime.parse(row['day'] as String);
      result[day] = (row['total'] as num).toDouble();
    }
    return result;
  }

  /// Returns the overall total of all transactions.
  Future<double> getGrandTotal() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseHelper.tableTransactions}',
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Returns the total for the current month.
  Future<double> getMonthTotal(DateTime month) async {
    final db = await _db;
    final startStr = '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
    // Calculate last day of month.
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final endStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}-$lastDay';
    final rows = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM ${DatabaseHelper.tableTransactions}
      WHERE DATE(date) BETWEEN ? AND ?
    ''', [startStr, endStr]);
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Returns the transaction count.
  Future<int> getCount() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${DatabaseHelper.tableTransactions}',
    );
    return (rows.first['cnt'] as int?) ?? 0;
  }
}
