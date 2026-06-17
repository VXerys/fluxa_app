abstract class VoiceAudioRecorderDataSource {
  Future<void> startRecording();
  Future<String> stopRecording();
  Future<void> cancelRecording();
  Future<double> getCurrentAmplitudeDb();
  Future<void> dispose();
}
