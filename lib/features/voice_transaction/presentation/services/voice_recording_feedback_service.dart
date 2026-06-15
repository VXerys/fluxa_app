import 'package:flutter/services.dart';

class VoiceRecordingFeedbackService {
  const VoiceRecordingFeedbackService();

  Future<void> playStart() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Feedback is best-effort and must never block recording.
    }
  }

  Future<void> playStop() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.selectionClick();
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
        await HapticFeedback.selectionClick();
      } catch (_) {
        // Feedback is best-effort and must never block upload/processing.
      }
    }
  }

  Future<void> playCancel() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Feedback is best-effort and must never block cancellation.
    }
  }

  Future<void> playError() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Feedback is best-effort and must never block failure handling.
    }
  }

  // TODO: For reliable custom voice assistant sounds, add short audio assets
  // and an audio player package later.
}
