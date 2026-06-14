import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/voice_transaction_repository.dart';

class StopVoiceRecordingUseCase implements UseCase<String, NoParams> {
  final VoiceTransactionRepository repository;

  StopVoiceRecordingUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.stopRecording();
  }
}
