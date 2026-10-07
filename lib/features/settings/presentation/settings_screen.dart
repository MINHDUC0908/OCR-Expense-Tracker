// lib/features/settings/presentation/settings_screen.dart
// Màn hình Cài đặt & Thông số kỹ thuật dự án bằng tiếng Việt.

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
        elevation: 0,
        title: Text(
          'Cài đặt & Thông tin dự án',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Header ứng dụng nhỏ gọn cân đối
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OCR Quản Lý Chi Tiêu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Dành cho Sinh viên & Thủ quỹ CLB',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Phiên bản 1.0.0 • ML Kit On-device',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tình huống vấn đề & giải pháp
          _SectionTitle(title: 'TÌNH HUỐNG VẤN ĐỀ & MỤC TIÊU'),
          _InfoCard(
            children: const [
              _InfoRow(
                icon: Icons.lightbulb_outline_rounded,
                iconColor: AppColors.primary,
                title: 'Hỗ trợ sinh viên & thủ quỹ',
                subtitle: 'Giảm thiểu thời gian nhập hóa đơn siêu thị thủ công vào bảng tính, hạn chế sai sót số liệu.',
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.speed_rounded,
                iconColor: AppColors.secondary,
                title: 'Xử lý OCR On-device < 100ms',
                subtitle: 'Google ML Kit quét trực tiếp trên chip điện thoại, không cần mạng, bảo mật và miễn phí 100%.',
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Công nghệ & tính năng cốt lõi
          _SectionTitle(title: 'THÔNG SỐ KỸ THUẬT CỐT LÕI'),
          _InfoCard(
            children: const [
              _InfoRow(
                icon: Icons.camera_alt_rounded,
                iconColor: AppColors.accent,
                title: 'Camera & Khung cắt thông minh',
                subtitle: 'Live view, bật/tắt flash, chạm lấy nét, khung căn chỉnh A4 chuẩn hóa đơn.',
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.rule_rounded,
                iconColor: AppColors.success,
                title: 'Regex trích xuất phỏng đoán',
                subtitle: 'Tự động bóc tách: Tổng tiền (VND, đ), ngày tháng (DD/MM/YYYY), tên đơn vị bán.',
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.draw_rounded,
                iconColor: AppColors.catTravel,
                title: 'CustomPainter Canvas Chart',
                subtitle: 'Biểu đồ bánh vòng & cột vẽ mượt mà trực tiếp trên Canvas, không dùng thư viện ngoài.',
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.storage_rounded,
                iconColor: AppColors.warning,
                title: 'Cơ sở dữ liệu SQLite cục bộ',
                subtitle: 'Lưu trữ giao dịch lâu dài và sao lưu ảnh chụp biên lai vào bộ nhớ trong của ứng dụng.',
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 5 Danh mục chi tiêu theo quy chuẩn
          _SectionTitle(title: '5 DANH MỤC CHI TIÊU QUY CHUẨN'),
          _InfoCard(
            children: const [
              _CategoryRow(emoji: '🍔', name: 'Thực phẩm', desc: 'Ăn uống, siêu thị, cà phê, nhà hàng'),
              _Divider(),
              _CategoryRow(emoji: '📚', name: 'Học tập', desc: 'Sách vở, giáo trình, in ấn tài liệu, học phí'),
              _Divider(),
              _CategoryRow(emoji: '✈️', name: 'Du lịch', desc: 'Xăng xe, di chuyển, vé tàu xe, máy bay'),
              _Divider(),
              _CategoryRow(emoji: '🔧', name: 'Thiết bị', desc: 'Linh kiện, dụng cụ, đồ điện tử, thiết bị CLB'),
              _Divider(),
              _CategoryRow(emoji: '🎬', name: 'Giải trí', desc: 'Xem phim, sự kiện, thể thao, liên hoan CLB'),
            ],
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
          letterSpacing: 0.8,
          fontSize: 10.5,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
    return const Divider(height: 1, indent: 14, endIndent: 14);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 17))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
