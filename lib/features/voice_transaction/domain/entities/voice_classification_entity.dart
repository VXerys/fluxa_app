class VoiceClassificationEntity {
  final String rawType;
  final String resolvedType;
  final String category;

  const VoiceClassificationEntity({
    required this.rawType,
    required this.resolvedType,
    required this.category,
  });
}
