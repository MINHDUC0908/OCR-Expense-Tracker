// lib/features/camera/providers/camera_provider.dart
// Riverpod providers for camera lifecycle management.

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State held by [CameraNotifier].
class CameraState {
  final List<CameraDescription> cameras;
  final CameraController? controller;
  final bool isInitialized;
  final bool isFlashOn;
  final bool isTakingPicture;
  final String? errorMessage;

  const CameraState({
    this.cameras = const [],
    this.controller,
    this.isInitialized = false,
    this.isFlashOn = false,
    this.isTakingPicture = false,
    this.errorMessage,
  });

  CameraState copyWith({
    List<CameraDescription>? cameras,
    CameraController? controller,
    bool? isInitialized,
    bool? isFlashOn,
    bool? isTakingPicture,
    String? errorMessage,
  }) {
    return CameraState(
      cameras: cameras ?? this.cameras,
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
      errorMessage: errorMessage,
    );
  }
}

/// Manages the [CameraController] lifecycle and flash/focus controls.
class CameraNotifier extends AsyncNotifier<CameraState> {
  CameraController? _controller;

  @override
  Future<CameraState> build() async {
    // Discover available cameras.
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return const CameraState(errorMessage: 'No cameras available');
    }

    // Use the first back-facing camera.
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    // Initialize controller with high resolution for OCR quality.
    _controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: false,
    );

    await _controller!.initialize();

    // Ensure controller is disposed when the provider is disposed.
    ref.onDispose(() {
      _controller?.dispose();
    });

    return CameraState(
      cameras: cameras,
      controller: _controller,
      isInitialized: true,
    );
  }

  /// Toggles flash between on/off.
  Future<void> toggleFlash() async {
    final current = state.valueOrNull;
    if (current?.controller == null || !current!.isInitialized) return;

    final newFlashState = !current.isFlashOn;
    await _controller!.setFlashMode(
      newFlashState ? FlashMode.torch : FlashMode.off,
    );

    state = AsyncData(current.copyWith(isFlashOn: newFlashState));
  }

  /// Sets the camera focus point to [normalizedPoint] (0.0–1.0).
  Future<void> focusAt(Offset normalizedPoint) async {
    final current = state.valueOrNull;
    if (current?.controller == null || !current!.isInitialized) return;

    try {
      await _controller!.setFocusPoint(normalizedPoint);
      await _controller!.setExposurePoint(normalizedPoint);
    } catch (_) {
      // Some devices don't support manual focus; silently ignore.
    }
  }

  /// Captures a photo and returns the file path.
  /// Returns null if capture fails.
  Future<String?> takePicture() async {
    final current = state.valueOrNull;
    if (current?.controller == null ||
        !current!.isInitialized ||
        current.isTakingPicture) return null;

    state = AsyncData(current.copyWith(isTakingPicture: true));

    try {
      final file = await _controller!.takePicture();
      return file.path;
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isTakingPicture: false,
          errorMessage: 'Failed to capture: $e',
        ),
      );
      return null;
    } finally {
      final s = state.valueOrNull;
      if (s != null) {
        state = AsyncData(s.copyWith(isTakingPicture: false));
      }
    }
  }
}

/// The primary camera provider used in [CameraScreen].
final cameraNotifierProvider =
    AsyncNotifierProvider<CameraNotifier, CameraState>(CameraNotifier.new);
