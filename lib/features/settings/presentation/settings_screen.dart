// lib/features/settings/presentation/settings_screen.dart
// Settings & Information screen for OCR Expense Tracker.

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // App Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                Text('OCR Expense Tracker', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 4),
                Text('Version 1.0.0 (On-device ML Kit)', style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // OCR & Model Info Section
          _SectionTitle(title: 'OCR ENGINE'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.bolt_rounded, color: AppColors.primary),
                  title: Text('Google ML Kit Text Recognition'),
                  subtitle: Text('Offline, On-Device, Low Latency'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.info),
                  title: const Text('Supported Script'),
                  subtitle: const Text('Latin (Vietnamese & English receipts)'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Categories Overview
          _SectionTitle(title: 'EXPENSE CATEGORIES'),
          Card(
            child: Column(
              children: [
                _CategoryRow(emoji: '🍔', name: 'Food', desc: 'Meals, coffee, restaurants'),
                const Divider(),
                _CategoryRow(emoji: '📚', name: 'Study', desc: 'Books, tuition, materials'),
                const Divider(),
                _CategoryRow(emoji: '✈️', name: 'Travel', desc: 'Fuel, bus, taxi, flights'),
                const Divider(),
                _CategoryRow(emoji: '🔧', name: 'Gear', desc: 'Hardware, electronics, tools'),
                const Divider(),
                _CategoryRow(emoji: '🎬', name: 'Entertainment', desc: 'Movies, gaming, leisure'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Storage Info
          _SectionTitle(title: 'LOCAL DATABASE'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_rounded, color: AppColors.warning),
              title: const Text('SQLite (sqflite)'),
              subtitle: const Text('Encrypted locally in application documents directory'),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String emoji;
  final String name;
  final String desc;

  const _CategoryRow({
    required this.emoji,
    required this.name,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(name, style: AppTextStyles.titleSmall),
      subtitle: Text(desc, style: AppTextStyles.bodySmall),
    );
  }
}
