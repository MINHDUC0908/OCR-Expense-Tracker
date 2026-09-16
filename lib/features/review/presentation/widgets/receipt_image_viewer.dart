import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ReceiptImageViewer extends StatefulWidget {
  final String imagePath;
  final String rawText;
  final double confidence;

  const ReceiptImageViewer({
    super.key,
    required this.imagePath,
    required this.rawText,
    required this.confidence,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with confidence indicator and Raw Text toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      size: 18,
                      color: widget.confidence >= 0.66
                          ? AppColors.success
                          : (widget.confidence > 0.3
                              ? AppColors.warning
                              : AppColors.error),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Độ tin cậy OCR: ${(widget.confidence * 100).toInt()}%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                    size: 16,
                  ),
                  label: Text(_showRawText ? 'Xem ảnh' : 'Văn bản OCR'),
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
            duration: const Duration(milliseconds: 250),
            crossFadeState: _showRawText
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: hasValidFile
                ? Container(
                    height: 220,
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
                    height: 160,
                    color: AppColors.surfaceVariant,
                    alignment: Alignment.center,
                    child: const Text('Không có ảnh xem trước'),
                  ),
            secondChild: Container(
              height: 220,
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
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
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
