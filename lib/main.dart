// lib/main.dart
// Entry point for OCR Expense Tracker application.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local database before the app starts.
  await DatabaseHelper.instance.database;

  runApp(
    // ProviderScope is required at the root for Riverpod.
    const ProviderScope(
      child: OcrExpenseTrackerApp(),
    ),
  );
}

class OcrExpenseTrackerApp extends ConsumerWidget {
  const OcrExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'OCR Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
