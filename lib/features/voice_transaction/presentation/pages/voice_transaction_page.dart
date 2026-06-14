import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/icons/app_huge_icons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../controllers/voice_transaction_controller.dart';
import '../widgets/voice_processing_state_widget.dart';
import '../widgets/voice_record_button_widget.dart';
import '../widgets/voice_transcript_preview_widget.dart';
import '../widgets/voice_transaction_draft_card_widget.dart';

class VoiceTransactionPage extends GetView<VoiceTransactionController> {
  const VoiceTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Catat dengan Suara',
          style: AppTextStyles.lora20w600.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const AppIcon(
            AppHugeIcons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final VoiceTransactionState state = controller.state;
          final result = controller.result;
          final voiceResult = result;
          final bool showSuccessState =
              state == VoiceTransactionState.success && voiceResult != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: VoiceRecordButtonWidget(
                      state: state,
                      onStart: controller.startRecording,
                      onCancel: controller.cancelRecording,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                VoiceProcessingStateWidget(
                  state: state,
                  failureMessage: controller.failureMessage,
                  recordingElapsedMs: controller.recordingElapsedMs,
                  showContinuingHint: controller.showContinuingHint,
                  onRetry: controller.retryParse,
                  onRecordAgain: controller.resetDraft,
                ),
                if (showSuccessState) ...[
                  const SizedBox(height: AppSpacing.s16),
                  VoiceTranscriptPreviewWidget(
                    transcript: voiceResult!.transcript,
                  ),
                  if (voiceResult.warnings.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s16),
                    _WarningsCard(warnings: voiceResult.warnings),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  VoiceTransactionDraftCardWidget(
                    transaction: voiceResult.transaction,
                    draft: controller.draft,
                  ),
                  if (controller.missingDraftFields.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s16),
                    _DraftMissingFieldsCard(
                      missingFields: controller.missingDraftFields,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  _SuccessActions(controller: controller),
                ],
                const SizedBox(height: AppSpacing.s32),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SuccessActions extends StatelessWidget {
  final VoiceTransactionController controller;

  const _SuccessActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isComplete = controller.isDraftComplete;
      final bool isSaving = controller.isSavingDraft;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: isSaving
                ? null
                : isComplete
                ? controller.saveDraftAsTransaction
                : controller.openAddTransactionWithDraft,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isSaving
                  ? 'Menyimpan...'
                  : isComplete
                  ? 'Simpan Transaksi'
                  : 'Lengkapi Detail',
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          if (isComplete) ...[
            OutlinedButton(
              onPressed: isSaving ? null : controller.editDraft,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                side: BorderSide(
                  color: AppColors.neutral.withValues(alpha: 0.24),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Edit Detail'),
            ),
            const SizedBox(height: AppSpacing.s4),
          ],
          TextButton(
            onPressed: isSaving ? null : controller.resetDraft,
            child: Text(
              'Rekam ulang',
              style: AppTextStyles.roboto13w500.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _DraftMissingFieldsCard extends StatelessWidget {
  final List<String> missingFields;

  const _DraftMissingFieldsCard({required this.missingFields});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masih perlu dilengkapi',
            style: AppTextStyles.roboto16w600.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            missingFields.join(', '),
            style: AppTextStyles.roboto13w400.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningsCard extends StatelessWidget {
  final List<String> warnings;

  const _WarningsCard({required this.warnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perlu perhatian',
            style: AppTextStyles.roboto16w600.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          for (final warning in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s4),
              child: Text(
                '- $warning',
                style: AppTextStyles.roboto13w400.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
