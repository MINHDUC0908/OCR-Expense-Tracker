import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ReceiptImageViewer extends StatefulWidget {
  final String imagePath;
  final String rawText;
  final double confidence;
  final int processingTimeMs;

  const ReceiptImageViewer({
    super.key,
    required this.imagePath,
    required this.rawText,
    required this.confidence,
    this.processingTimeMs = 0,
  });

  @override
  State<ReceiptImageViewer> createState() => _ReceiptImageViewerState();
}

class _ReceiptImageViewerState extends State<ReceiptImageViewer> {
  bool _showRawText = false;

  @override
  Widget build(BuildContext context) {
    final hasValidFile =
        widget.imagePath.isNotEmpty &&
        File(widget.imagePath).existsSync();

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with confidence indicator, speed badge, and Raw Text toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.confidence >= 0.66
                          ? Icons.check_circle_rounded
                          : (widget.confidence > 0.3
                              ? Icons.info_rounded
                              : Icons.warning_amber_rounded),
                      size: 15,
                      color: widget.confidence >= 0.66
                          ? AppColors.success
                          : (widget.confidence > 0.3
                              ? AppColors.warning
                              : AppColors.error),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'OCR: ${(widget.confidence * 100).toInt()}%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    if (widget.processingTimeMs > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '⚡ ${widget.processingTimeMs}ms (offline)',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRawText = !_showRawText;
                    });
                  },
                  icon: Icon(
                    _showRawText ? Icons.image_rounded : Icons.text_snippet_rounded,
                    size: 14,
                  ),
                  label: Text(
                    _showRawText ? 'Xem ảnh' : 'Văn bản OCR',
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          // Main View: Image or Extracted Raw Text
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _showRawText
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: hasValidFile
                ? Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black,
                    child: InteractiveViewer(
                      maxScale: 3.5,
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Container(
                    height: 140,
                    color: AppColors.surfaceVariant,
                    alignment: Alignment.center,
                    child: Text('Không có ảnh xem trước', style: AppTextStyles.bodySmall),
                  ),
            secondChild: Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.background,
              child: SingleChildScrollView(
                child: SelectableText(
                  widget.rawText.isNotEmpty
                      ? widget.rawText
                      : 'Không nhận diện được văn bản nào từ ảnh này.',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
