import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/icons/app_huge_icons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../controllers/voice_transaction_controller.dart';

class VoiceProcessingStateWidget extends StatelessWidget {
  final VoiceTransactionState state;
  final String failureMessage;
  final int recordingElapsedMs;
  final bool hasDetectedSpeech;
  final bool showContinuingHint;
  final VoidCallback onRetry;
  final VoidCallback onRecordAgain;

  const VoiceProcessingStateWidget({
    super.key,
    required this.state,
    required this.failureMessage,
    required this.recordingElapsedMs,
    required this.hasDetectedSpeech,
    required this.showContinuingHint,
    required this.onRetry,
    required this.onRecordAgain,
  });

  @override
  Widget build(BuildContext context) {
    if (state == VoiceTransactionState.idle) {
      return _MessageBlock(
        icon: AppHugeIcons.mic_none,
        title: 'Tap untuk mulai rekam',
        message: 'Contoh: beli kopi 15 ribu pakai BCA',
        color: AppColors.primary,
      );
    }

    if (state == VoiceTransactionState.recording) {
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
            Row(
              children: [
                const AppIcon(
                  AppHugeIcons.mic_none,
                  color: AppColors.error,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    'Mendengarkan...',
                    style: AppTextStyles.roboto16w600.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  _formatDuration(recordingElapsedMs),
                  style: AppTextStyles.roboto13w600.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              showContinuingHint
                  ? 'Memproses sebentar...'
                  : hasDetectedSpeech
                  ? 'Bicara natural, sistem akan berhenti otomatis.'
                  : 'Silakan mulai bicara.',
              style: AppTextStyles.roboto13w400.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state == VoiceTransactionState.processing ||
        state == VoiceTransactionState.uploading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                state == VoiceTransactionState.uploading
                    ? 'Mengupload audio...'
                    : 'Memproses suara dengan AI...\nIni bisa sedikit lebih lama karena server gratis.',
                style: AppTextStyles.roboto14w500.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state == VoiceTransactionState.failure) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gagal memproses audio',
              style: AppTextStyles.roboto16w600.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              failureMessage.isEmpty
                  ? 'Terjadi kegagalan saat memproses voice.'
                  : failureMessage,
              style: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const AppIcon(
                      AppHugeIcons.replay_outlined,
                      size: 18,
                    ),
                    label: const Text('Retry'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRecordAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Rekam ulang'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return _MessageBlock(
      icon: AppHugeIcons.check,
      title: 'Draft berhasil dibuat',
      message: 'Periksa kembali hasil AI sebelum menyimpan transaksi final.',
      color: AppColors.success,
    );
  }

  String _formatDuration(int milliseconds) {
    final int totalSeconds = milliseconds ~/ 1000;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _MessageBlock extends StatelessWidget {
  final AppIconData icon;
  final String title;
  final String message;
  final Color color;

  const _MessageBlock({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Center(child: AppIcon(icon, color: color, size: 24)),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.roboto16w600.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  message,
                  style: AppTextStyles.roboto13w400.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
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
