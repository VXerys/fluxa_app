import '../../domain/entities/voice_transaction_result_entity.dart';
import 'voice_classification_model.dart';
import 'voice_transaction_model.dart';
import 'voice_transcript_model.dart';

class VoiceTransactionResultModel extends VoiceTransactionResultEntity {
  const VoiceTransactionResultModel({
    required VoiceTranscriptModel transcript,
    required VoiceTransactionModel transaction,
    required VoiceClassificationModel classification,
    required List<String> warnings,
  }) : super(
         transcript: transcript,
         transaction: transaction,
         classification: classification,
         warnings: warnings,
       );

  factory VoiceTransactionResultModel.fromJson(Map<String, dynamic> json) {
    return VoiceTransactionResultModel(
      transcript: VoiceTranscriptModel.fromJson(
        _readMap(json['transcript']),
      ),
      transaction: VoiceTransactionModel.fromJson(
        _readMap(json['transaction']),
      ),
      classification: VoiceClassificationModel.fromJson(
        _readMap(json['classification']),
      ),
      warnings: _readStringList(json['warnings']),
    );
  }

  VoiceTransactionResultEntity toEntity() {
    return VoiceTransactionResultEntity(
      transcript: (transcript as VoiceTranscriptModel).toEntity(),
      transaction: (transaction as VoiceTransactionModel).toEntity(),
      classification: (classification as VoiceClassificationModel).toEntity(),
      warnings: List<String>.unmodifiable(warnings),
    );
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value.map((item) => item.toString()).toList(growable: false);
  }
}
