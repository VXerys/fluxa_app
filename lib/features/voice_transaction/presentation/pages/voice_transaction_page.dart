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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: VoiceRecordButtonWidget(
                    state: state,
                    onStart: controller.startRecording,
                    onCancel: controller.cancelRecording,
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
                if (result != null) ...[
                  const SizedBox(height: AppSpacing.s16),
                  VoiceTranscriptPreviewWidget(transcript: result.transcript),
                  if (result.warnings.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s16),
                    _WarningsCard(warnings: result.warnings),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  VoiceTransactionDraftCardWidget(
                    transaction: result.transaction,
                    onSave: controller.handleSaveDraftTodo,
                    onEdit: controller.handleEditDraftTodo,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  OutlinedButton(
                    onPressed: controller.resetDraft,
                    child: const Text('Rekam ulang'),
                  ),
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
