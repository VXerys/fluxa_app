import '../../domain/entities/voice_classification_entity.dart';

class VoiceClassificationModel extends VoiceClassificationEntity {
  const VoiceClassificationModel({
    required super.rawType,
    required super.resolvedType,
    required super.category,
  });

  factory VoiceClassificationModel.fromJson(Map<String, dynamic> json) {
    return VoiceClassificationModel(
      rawType: json['raw_type'] as String? ?? '',
      resolvedType: json['resolved_type'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  VoiceClassificationEntity toEntity() {
    return VoiceClassificationEntity(
      rawType: rawType,
      resolvedType: resolvedType,
      category: category,
    );
  }
}
