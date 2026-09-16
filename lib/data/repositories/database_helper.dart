// lib/data/repositories/database_helper.dart
// Singleton sqflite database helper with schema and migration support.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _dbName = 'ocr_expense_tracker.db';
  static const int _dbVersion = 1;
  static const String tableTransactions = 'transactions';

  // Private constructor for singleton pattern.
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  /// Returns the singleton [Database] instance, creating it if necessary.
  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates the initial database schema.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id          TEXT PRIMARY KEY,
        amount      REAL NOT NULL,
        date        TEXT NOT NULL,
        merchant_name TEXT NOT NULL,
        category    TEXT NOT NULL,
        image_path  TEXT,
        created_at  TEXT NOT NULL
      )
    ''');

    // Index for faster queries by date.
    await db.execute('''
      CREATE INDEX idx_transactions_date ON $tableTransactions (date)
    ''');

    // Index for faster category filtering.
    await db.execute('''
      CREATE INDEX idx_transactions_category ON $tableTransactions (category)
    ''');
  }

  /// Handles schema migrations for future versions.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migration logic goes here.
  }

  /// Closes the database connection. Call on app teardown if needed.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
