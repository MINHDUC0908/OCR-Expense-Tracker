// lib/features/dashboard/presentation/widgets/bar_chart.dart
// CustomPainter-based Weekly Expense Bar Chart with animated rise and tap selection.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

class BarChartDataPoint {
  final String label; // e.g. "Mon", "Tue"
  final DateTime date;
  final double amount;

  const BarChartDataPoint({
    required this.label,
    required this.date,
    required this.amount,
  });
}

class WeeklyBarChart extends StatefulWidget {
  final List<BarChartDataPoint> weeklyData;

  const WeeklyBarChart({super.key, required this.weeklyData});

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(WeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weeklyData != widget.weeklyData) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    final step = size.width / widget.weeklyData.length;
    final tappedIndex = (details.localPosition.dx / step).floor();

    if (tappedIndex >= 0 && tappedIndex < widget.weeklyData.length) {
      setState(() {
        _selectedIndex = (_selectedIndex == tappedIndex) ? null : tappedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxAmount = widget.weeklyData.fold<double>(
      0.0,
      (max, e) => math.max(max, e.amount),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Bar Value Tooltip / Header
        Container(
          height: 32,
          alignment: Alignment.centerLeft,
          child: _selectedIndex != null && _selectedIndex! < widget.weeklyData.length
              ? Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.weeklyData[_selectedIndex!].label}: ',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      CurrencyFormatter.formatVnd(widget.weeklyData[_selectedIndex!].amount),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Chạm vào cột để xem chi tiết ngày',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
        ),

        const SizedBox(height: 8),

        // Custom Painted Canvas
        SizedBox(
          height: 160,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) =>
                    _handleTapDown(details, Size(constraints.maxWidth, 160)),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(constraints.maxWidth, 160),
                      painter: _BarChartPainter(
                        data: widget.weeklyData,
                        maxAmount: maxAmount > 0 ? maxAmount : 1.0,
                        progress: _animation.value,
                        selectedIndex: _selectedIndex,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<BarChartDataPoint> data;
  final double maxAmount;
  final double progress;
  final int? selectedIndex;

  const _BarChartPainter({
    required this.data,
    required this.maxAmount,
    required this.progress,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final bottomAxisHeight = 24.0;
    final chartHeight = size.height - bottomAxisHeight;
    final barWidth = math.min(size.width / (data.length * 2.2), 24.0);
    final step = size.width / data.length;

    // Draw background guide gridlines (3 lines)
    final gridPaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    for (int g = 1; g <= 3; g++) {
      final y = chartHeight * (1.0 - (g / 3.0));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final centerX = (i * step) + (step / 2);
      final isSelected = selectedIndex == i;

      // Calculate bar height based on ratio * progress
      final barHeight = (point.amount / maxAmount) * (chartHeight - 16) * progress;
      final topY = chartHeight - math.max(barHeight, 4.0); // minimum stub

      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - (barWidth / 2),
          topY,
          barWidth,
          chartHeight - topY,
        ),
        const Radius.circular(6),
      );

      // Bar gradient / color
      final barPaint = Paint()
        ..color = isSelected
            ? AppColors.primary
            : (point.amount > 0 ? AppColors.primary.withValues(alpha: 0.5) : AppColors.surfaceElevated);

      canvas.drawRRect(barRect, barPaint);

      // Active border if selected
      if (isSelected) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRRect(barRect, borderPaint);
      }

      // X-Axis Label (Mon, Tue, ...)
      textPainter.text = TextSpan(
        text: point.label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX - (textPainter.width / 2), chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data;
  }
}
