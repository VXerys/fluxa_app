import '../../domain/entities/voice_transcript_entity.dart';

class VoiceTranscriptModel extends VoiceTranscriptEntity {
  const VoiceTranscriptModel({
    required super.raw,
    required super.normalized,
    required super.languageHint,
    required super.confidence,
  });

  factory VoiceTranscriptModel.fromJson(Map<String, dynamic> json) {
    return VoiceTranscriptModel(
      raw: json['raw'] as String? ?? '',
      normalized: json['normalized'] as String? ?? '',
      languageHint: json['language_hint'] as String? ?? '',
      confidence: _parseDouble(json['confidence']),
    );
  }

  VoiceTranscriptEntity toEntity() {
    return VoiceTranscriptEntity(
      raw: raw,
      normalized: normalized,
      languageHint: languageHint,
      confidence: confidence,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
