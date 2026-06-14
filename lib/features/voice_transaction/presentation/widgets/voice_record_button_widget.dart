import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/icons/app_huge_icons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../controllers/voice_transaction_controller.dart';

class VoiceRecordButtonWidget extends StatefulWidget {
  final VoiceTransactionState state;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  const VoiceRecordButtonWidget({
    super.key,
    required this.state,
    required this.onStart,
    required this.onCancel,
  });

  @override
  State<VoiceRecordButtonWidget> createState() =>
      _VoiceRecordButtonWidgetState();
}

class _VoiceRecordButtonWidgetState extends State<VoiceRecordButtonWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant VoiceRecordButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == VoiceTransactionState.recording) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRecording = widget.state == VoiceTransactionState.recording;
    final bool isBusy =
        widget.state == VoiceTransactionState.uploading ||
        widget.state == VoiceTransactionState.processing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: GestureDetector(
            onTap: isBusy || isRecording ? null : widget.onStart,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? AppColors.error : AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? AppColors.error : AppColors.primary)
                        .withValues(alpha: isRecording ? 0.34 : 0.26),
                    blurRadius: isRecording ? 28 : 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: isBusy
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: AppColors.surface,
                          strokeWidth: 2.4,
                        ),
                      )
                    : const AppIcon(
                        AppHugeIcons.mic_none,
                        color: AppColors.surface,
                        size: 46,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          isRecording ? 'Mendengarkan...' : 'Tap untuk mulai rekam',
          style: AppTextStyles.roboto14w600.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        if (isRecording) ...[
          const SizedBox(height: AppSpacing.s8),
          TextButton(
            onPressed: widget.onCancel,
            child: Text(
              'Batalkan',
              style: AppTextStyles.roboto14w500.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
