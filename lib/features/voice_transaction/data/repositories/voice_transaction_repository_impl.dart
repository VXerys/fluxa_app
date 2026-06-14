import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/voice_transaction_result_entity.dart';
import '../../domain/repositories/voice_transaction_repository.dart';
import '../datasources/voice_audio_recorder_datasource.dart';
import '../datasources/voice_transaction_remote_datasource.dart';

class VoiceTransactionRepositoryImpl implements VoiceTransactionRepository {
  final VoiceAudioRecorderDataSource audioRecorderDataSource;
  final VoiceTransactionRemoteDataSource remoteDataSource;

  VoiceTransactionRepositoryImpl({
    required this.audioRecorderDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, void>> startRecording() async {
    try {
      await audioRecorderDataSource.startRecording();
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, String>> stopRecording() async {
    try {
      final String audioPath = await audioRecorderDataSource.stopRecording();
      return Right(audioPath);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRecording() async {
    try {
      await audioRecorderDataSource.cancelRecording();
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, double>> getCurrentAmplitudeDb() async {
    try {
      final double amplitudeDb =
          await audioRecorderDataSource.getCurrentAmplitudeDb();
      return Right(amplitudeDb);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> disposeRecorder() async {
    try {
      await audioRecorderDataSource.dispose();
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, VoiceTransactionResultEntity>> parseVoiceTransaction(
    String audioFilePath,
  ) async {
    try {
      final result = await remoteDataSource.parseVoiceTransaction(
        audioFilePath,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  Failure _mapException(Object error) {
    if (error is AuthException) return AuthFailure(error.message);
    if (error is NetworkException) return NetworkFailure(error.message);
    if (error is CacheException) return CacheFailure(error.message);
    if (error is PermissionException) return PermissionFailure(error.message);
    if (error is ValidationException) return ValidationFailure(error.message);
    if (error is ServerException) return ServerFailure(error.message);
    return ServerFailure(error.toString());
  }
}
