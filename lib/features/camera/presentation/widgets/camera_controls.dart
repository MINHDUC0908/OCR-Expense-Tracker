// lib/features/camera/presentation/widgets/camera_controls.dart
// Bottom control bar: flash toggle + capture button.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CameraControls extends StatelessWidget {
  final bool isFlashOn;
  final bool isTakingPicture;
  final VoidCallback onFlashToggle;
  final VoidCallback onCapture;
  final VoidCallback onGallery;

  const CameraControls({
    super.key,
    required this.isFlashOn,
    required this.isTakingPicture,
    required this.onFlashToggle,
    required this.onCapture,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.black87,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gallery shortcut.
            _CircleIconButton(
              icon: Icons.photo_library_outlined,
              onTap: onGallery,
              tooltip: 'Thư viện ảnh',
            ),

            // Main capture button.
            _CaptureButton(
              isBusy: isTakingPicture,
              onTap: isTakingPicture ? null : onCapture,
            ),

            // Flash toggle.
            _CircleIconButton(
              icon: isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              onTap: onFlashToggle,
              tooltip: isFlashOn ? 'Tắt đèn flash' : 'Bật đèn flash',
              activeColor: isFlashOn ? AppColors.warning : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureButton extends StatefulWidget {
  final bool isBusy;
  final VoidCallback? onTap;

  const _CaptureButton({required this.isBusy, this.onTap});

  @override
  State<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _scaleController.drive(Tween(begin: 0.85, end: 1.0));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;
    await _scaleController.reverse();
    widget.onTap!();
    await _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            color: Colors.transparent,
          ),
          padding: const EdgeInsets.all(8),
          child: widget.isBusy
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                )
              : Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? activeColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white12,
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Icon(
            icon,
            color: activeColor ?? Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
