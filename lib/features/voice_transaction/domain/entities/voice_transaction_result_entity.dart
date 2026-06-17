import 'voice_classification_entity.dart';
import 'voice_transaction_entity.dart';
import 'voice_transcript_entity.dart';

class VoiceTransactionResultEntity {
  final VoiceTranscriptEntity transcript;
  final VoiceTransactionEntity transaction;
  final VoiceClassificationEntity classification;
  final List<String> warnings;

  const VoiceTransactionResultEntity({
    required this.transcript,
    required this.transaction,
    required this.classification,
    required this.warnings,
  });
}
