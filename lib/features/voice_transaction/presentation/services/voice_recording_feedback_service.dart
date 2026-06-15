import 'package:flutter/services.dart';

class VoiceRecordingFeedbackService {
  VoiceRecordingFeedbackService._();

  static Future<void> playStartFeedback() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Feedback is best-effort and must never block recording.
    }
  }

  static Future<void> playStopFeedback() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.selectionClick();
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
        await HapticFeedback.lightImpact();
      } catch (_) {
        // Feedback is best-effort and must never block upload/processing.
      }
    }
  }

  static Future<void> playCancelFeedback() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Feedback is best-effort and must never block cancellation.
    }
  }
}
