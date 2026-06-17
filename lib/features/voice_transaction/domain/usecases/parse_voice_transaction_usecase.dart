import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/voice_transaction_result_entity.dart';
import '../repositories/voice_transaction_repository.dart';

class ParseVoiceTransactionParams {
  final String audioFilePath;

  const ParseVoiceTransactionParams({required this.audioFilePath});
}

class ParseVoiceTransactionUseCase
    implements
        UseCase<VoiceTransactionResultEntity, ParseVoiceTransactionParams> {
  final VoiceTransactionRepository repository;

  ParseVoiceTransactionUseCase({required this.repository});

  @override
  Future<Either<Failure, VoiceTransactionResultEntity>> call(
    ParseVoiceTransactionParams params,
  ) {
    if (params.audioFilePath.trim().isEmpty) {
      return Future.value(
        Left<Failure, VoiceTransactionResultEntity>(
          const ValidationFailure('File audio belum tersedia'),
        ),
      );
    }
    return repository.parseVoiceTransaction(params.audioFilePath);
  }
}
