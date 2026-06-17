import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/voice_transcript_entity.dart';

class VoiceTranscriptPreviewWidget extends StatefulWidget {
  final VoiceTranscriptEntity transcript;

  const VoiceTranscriptPreviewWidget({super.key, required this.transcript});

  @override
  State<VoiceTranscriptPreviewWidget> createState() =>
      _VoiceTranscriptPreviewWidgetState();
}

class _VoiceTranscriptPreviewWidgetState
    extends State<VoiceTranscriptPreviewWidget> {
  bool _showRawTranscript = false;

  @override
  Widget build(BuildContext context) {
    final VoiceTranscriptEntity transcript = widget.transcript;
    final String normalizedTranscript = transcript.normalized.isNotEmpty
        ? transcript.normalized
        : transcript.raw;
    final bool hasRawTranscript =
        transcript.raw.isNotEmpty && transcript.raw != normalizedTranscript;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transkrip',
            style: AppTextStyles.roboto16w600.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          Text(
            normalizedTranscript,
            style: AppTextStyles.roboto14w400.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (hasRawTranscript) ...[
            const SizedBox(height: AppSpacing.s8),
            TextButton(
              onPressed: () {
                setState(() {
                  _showRawTranscript = !_showRawTranscript;
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _showRawTranscript ? 'Sembunyikan raw' : 'Lihat raw',
                style: AppTextStyles.roboto12w600.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            if (_showRawTranscript) ...[
              const SizedBox(height: AppSpacing.s8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transcript.raw,
                  style: AppTextStyles.roboto13w400.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Bahasa: ${transcript.languageHint.isEmpty ? '-' : transcript.languageHint} | Confidence: ${(transcript.confidence * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.roboto12w400.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
