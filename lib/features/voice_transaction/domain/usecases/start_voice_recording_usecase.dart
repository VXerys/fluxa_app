import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/voice_transaction_repository.dart';

class StartVoiceRecordingUseCase implements UseCase<void, NoParams> {
  final VoiceTransactionRepository repository;

  StartVoiceRecordingUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.startRecording();
  }
}
