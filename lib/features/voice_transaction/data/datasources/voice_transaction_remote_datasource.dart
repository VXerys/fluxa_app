import '../models/voice_transaction_result_model.dart';

abstract class VoiceTransactionRemoteDataSource {
  Future<VoiceTransactionResultModel> parseVoiceTransaction(
    String audioFilePath,
  );
}
