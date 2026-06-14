import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/voice_transaction_repository.dart';

class DisposeVoiceRecorderUseCase implements UseCase<void, NoParams> {
  final VoiceTransactionRepository repository;

  DisposeVoiceRecorderUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.disposeRecorder();
  }
}
