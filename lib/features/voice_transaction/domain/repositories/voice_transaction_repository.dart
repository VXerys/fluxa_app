import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/voice_transaction_result_entity.dart';

abstract class VoiceTransactionRepository {
  Future<Either<Failure, void>> startRecording();
  Future<Either<Failure, String>> stopRecording();
  Future<Either<Failure, void>> cancelRecording();
  Future<Either<Failure, double>> getCurrentAmplitudeDb();
  Future<Either<Failure, void>> disposeRecorder();
  Future<Either<Failure, VoiceTransactionResultEntity>> parseVoiceTransaction(
    String audioFilePath,
  );
}
