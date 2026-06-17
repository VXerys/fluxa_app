import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/voice_transaction_repository.dart';

class GetVoiceRecordingAmplitudeUseCase implements UseCase<double, NoParams> {
  final VoiceTransactionRepository repository;

  GetVoiceRecordingAmplitudeUseCase({required this.repository});

  @override
  Future<Either<Failure, double>> call(NoParams params) {
    return repository.getCurrentAmplitudeDb();
  }
}
