// lib/features/camera/presentation/widgets/camera_overlay.dart
// CustomPainter that draws the receipt crop guide overlay on the viewfinder.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Semi-transparent overlay with a receipt-ratio rectangular cutout.
/// The cutout area shows the live camera preview clearly while the
/// surrounding area is dimmed.
class CameraOverlay extends StatefulWidget {
  const CameraOverlay({super.key});

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Subtle pulsing animation on the crop border.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) {
        return CustomPaint(
          painter: _OverlayPainter(borderOpacity: _pulseAnimation.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double borderOpacity;

  const _OverlayPainter({required this.borderOpacity});

  // Receipt aspect ratio: A4-like (≈0.68 width : 1 height when portrait)
  static const double _receiptAspectRatio = 0.68;
  static const double _horizontalPadding = 32.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the crop rect.
    final cropWidth = size.width - (_horizontalPadding * 2);
    final cropHeight = cropWidth / _receiptAspectRatio;
    final cropTop = (size.height - cropHeight) / 2;

    final cropRect = Rect.fromLTWH(
      _horizontalPadding,
      cropTop,
      cropWidth,
      cropHeight,
    );

    // Draw dimmed overlay outside crop rect.
    final overlayPaint = Paint()..color = Colors.black54;
    // Top region.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, cropTop),
      overlayPaint,
    );
    // Bottom region.
    canvas.drawRect(
      Rect.fromLTWH(
          0, cropTop + cropHeight, size.width, size.height - cropTop - cropHeight),
      overlayPaint,
    );
    // Left strip.
    canvas.drawRect(
      Rect.fromLTWH(0, cropTop, _horizontalPadding, cropHeight),
      overlayPaint,
    );
    // Right strip.
    canvas.drawRect(
      Rect.fromLTWH(
          size.width - _horizontalPadding, cropTop, _horizontalPadding, cropHeight),
      overlayPaint,
    );

    // Draw crop border with pulsing teal color.
    final borderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: borderOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rRect = RRect.fromRectAndRadius(cropRect, const Radius.circular(4));
    canvas.drawRRect(rRect, borderPaint);

    // Draw corner handles for visual clarity.
    _drawCornerHandles(canvas, cropRect);
  }

  void _drawCornerHandles(Canvas canvas, Rect rect) {
    const handleLength = 20.0;
    const handleWidth = 3.5;
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = handleWidth
      ..strokeCap = StrokeCap.round;

    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];

    for (final corner in corners) {
      final isLeft = corner.dx == rect.left;
      final isTop = corner.dy == rect.top;

      final hSign = isLeft ? 1.0 : -1.0;
      final vSign = isTop ? 1.0 : -1.0;

      canvas.drawLine(
        corner,
        corner.translate(hSign * handleLength, 0),
        paint,
      );
      canvas.drawLine(
        corner,
        corner.translate(0, vSign * handleLength),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) =>
      oldDelegate.borderOpacity != borderOpacity;
}
