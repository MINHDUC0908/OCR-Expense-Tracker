// lib/features/settings/presentation/settings_screen.dart
// Màn hình Cài đặt bằng tiếng Việt

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Header ứng dụng
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'OCR Chi Tiêu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phiên bản 1.0.0 • ML Kit on-device',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Phần OCR Engine
          _SectionTitle(title: 'CÔNG NGHỆ OCR'),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.bolt_rounded,
                iconColor: AppColors.primary,
                title: 'Google ML Kit nhận diện chữ',
                subtitle: 'Hoạt động offline, xử lý trên thiết bị, độ trễ thấp',
              ),
              const _Divider(),
              _InfoRow(
                icon: Icons.language_rounded,
                iconColor: AppColors.secondary,
                title: 'Ngôn ngữ hỗ trợ',
                subtitle: 'Tiếng Việt & Tiếng Anh (hóa đơn Latin)',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Danh mục chi tiêu
          _SectionTitle(title: 'DANH MỤC CHI TIÊU'),
          _InfoCard(
            children: [
              _CategoryRow(emoji: '🍔', name: 'Ăn uống', desc: 'Bữa ăn, cà phê, nhà hàng'),
              const _Divider(),
              _CategoryRow(emoji: '📚', name: 'Học tập', desc: 'Sách, học phí, tài liệu'),
              const _Divider(),
              _CategoryRow(emoji: '✈️', name: 'Di chuyển', desc: 'Xăng, xe bus, taxi, máy bay'),
              const _Divider(),
              _CategoryRow(emoji: '🔧', name: 'Thiết bị', desc: 'Phần cứng, điện tử, dụng cụ'),
              const _Divider(),
              _CategoryRow(emoji: '🎬', name: 'Giải trí', desc: 'Phim, game, thư giãn'),
            ],
          ),

          const SizedBox(height: 20),

          // Lưu trữ
          _SectionTitle(title: 'CƠ SỞ DỮ LIỆU'),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.storage_rounded,
                iconColor: AppColors.warning,
                title: 'SQLite (sqflite)',
                subtitle: 'Lưu trữ an toàn tại thư mục ứng dụng trên thiết bị',
              ),
            ],
          ),

          const SizedBox(height: 32),
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
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: AppTextStyles.titleSmall),
      subtitle: Text(subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
      ),
      title: Text(name, style: AppTextStyles.titleSmall),
      subtitle: Text(desc,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
    );
  }
}
