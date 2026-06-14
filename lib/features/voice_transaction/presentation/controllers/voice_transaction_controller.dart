import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/voice_transaction_result_entity.dart';
import '../../domain/usecases/cancel_voice_recording_usecase.dart';
import '../../domain/usecases/dispose_voice_recorder_usecase.dart';
import '../../domain/usecases/get_voice_recording_amplitude_usecase.dart';
import '../../domain/usecases/parse_voice_transaction_usecase.dart';
import '../../domain/usecases/start_voice_recording_usecase.dart';
import '../../domain/usecases/stop_voice_recording_usecase.dart';

enum VoiceTransactionState {
  idle,
  recording,
  uploading,
  processing,
  success,
  failure,
}

class VoiceTransactionController extends GetxController {
  final StartVoiceRecordingUseCase startVoiceRecordingUseCase;
  final StopVoiceRecordingUseCase stopVoiceRecordingUseCase;
  final CancelVoiceRecordingUseCase cancelVoiceRecordingUseCase;
  final ParseVoiceTransactionUseCase parseVoiceTransactionUseCase;
  final DisposeVoiceRecorderUseCase disposeVoiceRecorderUseCase;
  final GetVoiceRecordingAmplitudeUseCase getVoiceRecordingAmplitudeUseCase;

  VoiceTransactionController({
    required this.startVoiceRecordingUseCase,
    required this.stopVoiceRecordingUseCase,
    required this.cancelVoiceRecordingUseCase,
    required this.parseVoiceTransactionUseCase,
    required this.disposeVoiceRecorderUseCase,
    required this.getVoiceRecordingAmplitudeUseCase,
  });

  static const int minRecordingDurationMs = 1500;
  static const int silenceBeforeSpeechTimeoutMs = 6000;
  static const int silenceAfterSpeechTimeoutMs = 3500;
  static const int maxRecordingDurationMs = 20000;
  static const int amplitudePollIntervalMs = 250;
  static const double speechAmplitudeThresholdDb = -35;
  static const int speechSamplesRequired = 2;

  final Rx<VoiceTransactionState> _state = VoiceTransactionState.idle.obs;
  VoiceTransactionState get state => _state.value;

  final Rx<VoiceTransactionResultEntity?> _result =
      Rx<VoiceTransactionResultEntity?>(null);
  VoiceTransactionResultEntity? get result => _result.value;

  final RxString _failureMessage = ''.obs;
  String get failureMessage => _failureMessage.value;

  final RxString _lastAudioPath = ''.obs;
  String get lastAudioPath => _lastAudioPath.value;

  final RxInt _recordingElapsedMs = 0.obs;
  int get recordingElapsedMs => _recordingElapsedMs.value;

  final RxBool _hasDetectedSpeech = false.obs;
  bool get hasDetectedSpeech => _hasDetectedSpeech.value;

  final RxBool _showContinuingHint = false.obs;
  bool get showContinuingHint => _showContinuingHint.value;

  Timer? _amplitudeTimer;
  DateTime? _recordingStartedAt;
  DateTime? _lastSpeechAt;
  bool _isEvaluatingRecording = false;
  int _speechSamplesAboveThreshold = 0;

  bool get isBusy =>
      state == VoiceTransactionState.uploading ||
      state == VoiceTransactionState.processing;

  Future<void> startRecording() async {
    if (isBusy || state == VoiceTransactionState.recording) return;

    _failureMessage.value = '';
    _result.value = null;
    final result = await startVoiceRecordingUseCase(const NoParams());
    result.fold(
      (failure) => _setFailure(failure.message),
      (_) {
        _state.value = VoiceTransactionState.recording;
        _startRecordingMonitoring();
      },
    );
  }

  Future<void> stopRecordingAndParse() async {
    if (state != VoiceTransactionState.recording) return;
    await _stopRecordingAndParse();
  }

  Future<void> _stopRecordingAndParse() async {
    _failureMessage.value = '';
    _stopRecordingMonitoring();
    _state.value = VoiceTransactionState.processing;

    final stopResult = await stopVoiceRecordingUseCase(const NoParams());
    await stopResult.fold(
      (failure) async => _setFailure(failure.message),
      (audioPath) async {
        _lastAudioPath.value = audioPath;
        await _parseAudioPath(audioPath);
      },
    );
  }

  Future<void> cancelRecording() async {
    if (isBusy) return;

    _stopRecordingMonitoring();
    final result = await cancelVoiceRecordingUseCase(const NoParams());
    result.fold(
      (failure) => _setFailure(failure.message),
      (_) {
        _lastAudioPath.value = '';
        _result.value = null;
        _failureMessage.value = '';
        _recordingElapsedMs.value = 0;
        _hasDetectedSpeech.value = false;
        _showContinuingHint.value = false;
        _state.value = VoiceTransactionState.idle;
      },
    );
  }

  Future<void> retryParse() async {
    if (isBusy) return;
    final String audioPath = _lastAudioPath.value.trim();
    if (audioPath.isEmpty) {
      _setFailure('File audio belum tersedia untuk dicoba ulang');
      return;
    }
    await _parseAudioPath(audioPath);
  }

  void resetDraft() {
    if (isBusy) return;
    _failureMessage.value = '';
    _result.value = null;
    _recordingElapsedMs.value = 0;
    _hasDetectedSpeech.value = false;
    _showContinuingHint.value = false;
    _state.value = VoiceTransactionState.idle;
  }

  void handleSaveDraftTodo() {
    Get.snackbar(
      'Belum tersedia',
      'Integrasi simpan transaksi final belum dihubungkan.',
    );
  }

  void handleEditDraftTodo() {
    Get.snackbar(
      'Belum tersedia',
      'Edit draft manual belum dihubungkan.',
    );
  }

  Future<void> _parseAudioPath(String audioPath) async {
    _state.value = VoiceTransactionState.uploading;
    final resultFuture = parseVoiceTransactionUseCase(
      ParseVoiceTransactionParams(audioFilePath: audioPath),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_state.value == VoiceTransactionState.uploading) {
      _state.value = VoiceTransactionState.processing;
    }
    final result = await resultFuture;
    result.fold(
      (failure) => _setFailure(failure.message),
      (voiceResult) {
        _result.value = voiceResult;
        _failureMessage.value = '';
        _state.value = VoiceTransactionState.success;
      },
    );
  }

  void _startRecordingMonitoring() {
    _stopRecordingMonitoring();
    _recordingStartedAt = DateTime.now();
    _lastSpeechAt = null;
    _recordingElapsedMs.value = 0;
    _hasDetectedSpeech.value = false;
    _showContinuingHint.value = false;
    _speechSamplesAboveThreshold = 0;
    _amplitudeTimer = Timer.periodic(
      const Duration(milliseconds: amplitudePollIntervalMs),
      (_) => unawaited(_evaluateRecordingAmplitude()),
    );
  }

  void _stopRecordingMonitoring() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _isEvaluatingRecording = false;
  }

  Future<void> _evaluateRecordingAmplitude() async {
    if (_isEvaluatingRecording || state != VoiceTransactionState.recording) {
      return;
    }

    final DateTime? startedAt = _recordingStartedAt;
    if (startedAt == null) return;

    _isEvaluatingRecording = true;
    try {
      final int elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
      _recordingElapsedMs.value = elapsedMs;

      final amplitudeResult = await getVoiceRecordingAmplitudeUseCase(
        const NoParams(),
      );
      amplitudeResult.fold((_) {}, (amplitudeDb) {
        if (amplitudeDb >= speechAmplitudeThresholdDb) {
          _speechSamplesAboveThreshold += 1;
          if (_speechSamplesAboveThreshold >= speechSamplesRequired) {
            _hasDetectedSpeech.value = true;
            _lastSpeechAt = DateTime.now();
            _showContinuingHint.value = false;
          }
        } else {
          _speechSamplesAboveThreshold = 0;
        }
      });

      if (state != VoiceTransactionState.recording) return;

      if (elapsedMs >= maxRecordingDurationMs) {
        await _stopRecordingAndParse();
        return;
      }

      if (elapsedMs < minRecordingDurationMs) return;

      if (!_hasDetectedSpeech.value &&
          elapsedMs >= silenceBeforeSpeechTimeoutMs) {
        await _cancelNoSpeechRecording();
        return;
      }

      final DateTime? lastSpeechAt = _lastSpeechAt;
      if (_hasDetectedSpeech.value && lastSpeechAt != null) {
        final int silenceMs = DateTime.now()
            .difference(lastSpeechAt)
            .inMilliseconds;
        _showContinuingHint.value = silenceMs >= 1250;
        if (silenceMs >= silenceAfterSpeechTimeoutMs) {
          await _stopRecordingAndParse();
        }
      }
    } finally {
      _isEvaluatingRecording = false;
    }
  }

  Future<void> _cancelNoSpeechRecording() async {
    _stopRecordingMonitoring();
    final result = await cancelVoiceRecordingUseCase(const NoParams());
    result.fold(
      (failure) => _setFailure(failure.message),
      (_) => _setFailure(
        'Suara belum terdengar. Coba rekam ulang lebih dekat ke mikrofon.',
      ),
    );
  }

  void _setFailure(String message) {
    _stopRecordingMonitoring();
    _failureMessage.value = message;
    _state.value = VoiceTransactionState.failure;
  }

  @override
  void onClose() {
    _stopRecordingMonitoring();
    unawaited(disposeVoiceRecorderUseCase(const NoParams()));
    super.onClose();
  }
}
