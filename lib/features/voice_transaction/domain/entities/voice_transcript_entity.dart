class VoiceTranscriptEntity {
  final String raw;
  final String normalized;
  final String languageHint;
  final double confidence;

  const VoiceTranscriptEntity({
    required this.raw,
    required this.normalized,
    required this.languageHint,
    required this.confidence,
  });
}
