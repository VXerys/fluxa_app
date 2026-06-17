import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/voice_transaction_repository.dart';

class CancelVoiceRecordingUseCase implements UseCase<void, NoParams> {
  final VoiceTransactionRepository repository;

  CancelVoiceRecordingUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.cancelRecording();
  }
}
