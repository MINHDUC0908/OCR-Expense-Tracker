// lib/features/dashboard/presentation/widgets/donut_chart.dart
// CustomPainter-based Donut chart with smooth sweep animation and interactive slice selection.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/expense_categories.dart';
import '../../../../core/utils/currency_formatter.dart';

class DonutChartData {
  final ExpenseCategory category;
  final double amount;

  const DonutChartData({required this.category, required this.amount});
}

class DonutChart extends StatefulWidget {
  final List<DonutChartData> data;
  final double totalAmount;

  const DonutChart({
    super.key,
    required this.data,
    required this.totalAmount,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
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
    if (widget.totalAmount <= 0 || widget.data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final touchPosition = details.localPosition;
    final dx = touchPosition.dx - center.dx;
    final dy = touchPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.62;

    // Check if tap falls within the donut ring
    if (distance < innerRadius || distance > outerRadius + 10) {
      setState(() => _selectedIndex = null);
      return;
    }

    // Calculate angle in radians [0, 2pi] starting from -pi/2 (top)
    var touchAngle = math.atan2(dy, dx);
    // Shift so 0 is at top (-pi/2)
    touchAngle += math.pi / 2;
    if (touchAngle < 0) touchAngle += 2 * math.pi;

    double currentAngle = 0.0;
    for (int i = 0; i < widget.data.length; i++) {
      final sweep = (widget.data[i].amount / widget.totalAmount) * 2 * math.pi;
      if (touchAngle >= currentAngle && touchAngle <= currentAngle + sweep) {
        setState(() {
          _selectedIndex = (_selectedIndex == i) ? null : i;
        });
        return;
      }
      currentAngle += sweep;
    }

    setState(() => _selectedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalAmount <= 0 || widget.data.isEmpty) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        child: Text(
          'Chưa có dữ liệu chi tiêu',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final chartSize = math.min(constraints.maxWidth, 220.0);
            return GestureDetector(
              onTapDown: (details) =>
                  _handleTapDown(details, Size(chartSize, chartSize)),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                       CustomPaint(
                        size: Size(chartSize, chartSize),
                        painter: _DonutChartPainter(
                          data: widget.data,
                          totalAmount: widget.totalAmount,
                          progress: _animation.value,
                          selectedIndex: _selectedIndex,
                        ),
                      ),
                      // Center info text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedIndex != null
                                ? widget.data[_selectedIndex!].category.displayName
                                : 'Tổng chi',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _selectedIndex != null
                                  ? widget.data[_selectedIndex!].category.color
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.formatCompact(
                              _selectedIndex != null
                                  ? widget.data[_selectedIndex!].amount
                                  : widget.totalAmount,
                            ),
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (_selectedIndex != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${((widget.data[_selectedIndex!].amount / widget.totalAmount) * 100).toStringAsFixed(1)}%',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: widget.data[_selectedIndex!].category.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Legend list
        Wrap(
          spacing: 16,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: widget.data.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isSelected = _selectedIndex == idx;
            final percent = ((item.amount / widget.totalAmount) * 100).toStringAsFixed(0);

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = isSelected ? null : idx;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.category.color.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? item.category.color : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.category.displayName} ($percent%)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutChartData> data;
  final double totalAmount;
  final double progress;
  final int? selectedIndex;

  const _DonutChartPainter({
    required this.data,
    required this.totalAmount,
    required this.progress,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalAmount <= 0 || data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 8;
    final strokeWidth = outerRadius * 0.32;

    double startAngle = -math.pi / 2; // Start from 12 o'clock

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = (item.amount / totalAmount) * 2 * math.pi * progress;
      final isSelected = selectedIndex == i;

      final paint = Paint()
        ..color = item.category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 6 : strokeWidth
        ..strokeCap = StrokeCap.butt;

      final rect = Rect.fromCircle(
        center: center,
        radius: isSelected ? outerRadius + 2 : outerRadius,
      );

      canvas.drawArc(
        rect,
        startAngle + (sweepAngle > 0.08 ? 0.02 : 0),
        sweepAngle > 0.08 ? sweepAngle - 0.04 : sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data;
  }
}
