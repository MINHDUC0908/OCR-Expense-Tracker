import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/camera_provider.dart';
import 'widgets/camera_controls.dart';
import 'widgets/camera_overlay.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  // Tap-to-focus indicator.
  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  @override
  Widget build(BuildContext context) {
    final cameraAsync = ref.watch(cameraNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _buildErrorView(error.toString()),
        data: (cameraState) {
          if (!cameraState.isInitialized || cameraState.controller == null) {
            return _buildErrorView(
              cameraState.errorMessage ?? 'Camera not available',
            );
          }
          return _buildCameraView(context, cameraState);
        },
      ),
    );
  }

  Widget _buildCameraView(BuildContext context, CameraState state) {
    return Stack(
      children: [
        // 1. Camera preview — fills entire screen.
        Positioned.fill(
          child: _ScaledCameraPreview(controller: state.controller!),
        ),

        // 2. Dimmed overlay with crop rectangle.
        const Positioned.fill(child: CameraOverlay()),

        // 3. Tap-to-focus gesture layer.
        Positioned.fill(
          child: GestureDetector(
            onTapUp: (details) => _handleTapToFocus(context, details),
            behavior: HitTestBehavior.translucent,
          ),
        ),

        // 4. Focus ring indicator.
        if (_showFocusIndicator && _focusPoint != null)
          Positioned(
            left: _focusPoint!.dx - 30,
            top: _focusPoint!.dy - 30,
            child: const _FocusRing(),
          ),

        // 5. Top bar: title + close.
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                const Expanded(
                  child: Text(
                    'Quét hóa đơn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // balance close button
              ],
            ),
          ),
        ),

        // 6. Hint text.
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 380),
            child: Text(
              'Đặt hóa đơn ngay ngắn trong khung',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ),
        ),

        // 7. Bottom controls.
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CameraControls(
            isFlashOn: state.isFlashOn,
            isTakingPicture: state.isTakingPicture,
            onFlashToggle: _toggleFlash,
            onCapture: _captureAndCrop,
            onGallery: _pickFromGallery,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(String message) {
    final isPermissionError = message.toLowerCase().contains('permission');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPermissionError ? Icons.no_photography_rounded : Icons.camera_alt_outlined,
              color: AppColors.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isPermissionError ? 'Cần cấp quyền Camera' : 'Camera không khả dụng',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isPermissionError) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await openAppSettings();
                },
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Mở Cài đặt'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: () {
                ref.invalidate(cameraNotifierProvider);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFlash() {
    ref.read(cameraNotifierProvider.notifier).toggleFlash();
  }

  Future<void> _handleTapToFocus(
      BuildContext context, TapUpDetails details) async {
    final size = context.size;
    if (size == null) return;

    setState(() {
      _focusPoint = details.localPosition;
      _showFocusIndicator = true;
    });

    // Normalize tap position to 0.0–1.0.
    final normalizedPoint = Offset(
      details.localPosition.dx / size.width,
      details.localPosition.dy / size.height,
    );

    await ref
        .read(cameraNotifierProvider.notifier)
        .focusAt(normalizedPoint);

    // Hide indicator after 1 second.
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _showFocusIndicator = false);
  }

  Future<void> _captureAndCrop() async {
    final imagePath =
        await ref.read(cameraNotifierProvider.notifier).takePicture();
    if (imagePath == null || !mounted) return;

    await _cropAndNavigate(imagePath);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    await _cropAndNavigate(picked.path);
  }

  Future<void> _cropAndNavigate(String imagePath) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cắt hóa đơn',
          toolbarColor: AppColors.surface,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: 'Cắt hóa đơn',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (cropped != null && mounted) {
      // Navigate to review screen with the cropped image path.
      context.push('/review', extra: cropped.path);
    }
  }
}

/// Scales the camera preview to cover the full screen,
/// maintaining the camera's native aspect ratio.
class _ScaledCameraPreview extends StatelessWidget {
  final CameraController controller;

  const _ScaledCameraPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = controller.value.previewSize;
        if (previewSize == null) return const SizedBox.shrink();

        final screenAspect = constraints.maxWidth / constraints.maxHeight;
        final previewAspect = previewSize.height / previewSize.width; // portrait

        double scale;
        if (previewAspect > screenAspect) {
          scale = constraints.maxWidth / (previewSize.height / previewSize.width * constraints.maxWidth);
        } else {
          scale = constraints.maxHeight / (previewSize.width / previewSize.height * constraints.maxHeight);
        }

        return Center(
          child: Transform.scale(
            scale: scale.isFinite ? scale : 1.0,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }
}

/// Animated focus ring displayed at tap point.
class _FocusRing extends StatefulWidget {
  const _FocusRing();

  @override
  State<_FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<_FocusRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scale = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warning, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
