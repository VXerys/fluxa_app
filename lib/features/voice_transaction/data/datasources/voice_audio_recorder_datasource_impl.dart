import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../core/errors/exceptions.dart';
import 'voice_audio_recorder_datasource.dart';

class VoiceAudioRecorderDataSourceImpl implements VoiceAudioRecorderDataSource {
  AudioRecorder _recorder;
  bool _isDisposed = false;
  String? _currentAudioPath;

  VoiceAudioRecorderDataSourceImpl({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  @override
  Future<void> startRecording() async {
    try {
      final AudioRecorder recorder = _activeRecorder();
      if (await recorder.isRecording()) {
        throw ServerException('Rekaman sedang berjalan');
      }

      final PermissionStatus status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw PermissionException('Izin mikrofon ditolak');
      }

      final bool hasPermission = await recorder.hasPermission();
      if (!hasPermission) {
        throw PermissionException('Izin mikrofon tidak tersedia');
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String audioPath =
          '${tempDir.path}${Platform.pathSeparator}'
          'fluxa_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: audioPath,
      );
      _currentAudioPath = audioPath;
    } on PermissionException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> stopRecording() async {
    try {
      final String? recordedPath = await _activeRecorder().stop();
      final String? audioPath = recordedPath ?? _currentAudioPath;
      _currentAudioPath = null;

      if (audioPath == null || audioPath.trim().isEmpty) {
        throw CacheException('File audio tidak ditemukan');
      }

      return audioPath;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> cancelRecording() async {
    final String? audioPath = _currentAudioPath;
    _currentAudioPath = null;

    try {
      final AudioRecorder recorder = _activeRecorder();
      if (await recorder.isRecording()) {
        await recorder.cancel();
      }
      if (audioPath != null && audioPath.isNotEmpty) {
        final File audioFile = File(audioPath);
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<double> getCurrentAmplitudeDb() async {
    try {
      final Amplitude amplitude = await _activeRecorder().getAmplitude();
      return amplitude.current;
    } catch (_) {
      return -160;
    }
  }

  @override
  Future<void> dispose() async {
    await _recorder.dispose();
    _isDisposed = true;
  }

  AudioRecorder _activeRecorder() {
    if (_isDisposed) {
      _recorder = AudioRecorder();
      _isDisposed = false;
    }
    return _recorder;
  }
}
