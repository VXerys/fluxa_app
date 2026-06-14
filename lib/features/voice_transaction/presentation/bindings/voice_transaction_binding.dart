import 'package:get/get.dart';

import '../../data/datasources/voice_audio_recorder_datasource.dart';
import '../../data/datasources/voice_audio_recorder_datasource_impl.dart';
import '../../data/datasources/voice_transaction_remote_datasource.dart';
import '../../data/datasources/voice_transaction_remote_datasource_impl.dart';
import '../../data/repositories/voice_transaction_repository_impl.dart';
import '../../domain/repositories/voice_transaction_repository.dart';
import '../../domain/usecases/cancel_voice_recording_usecase.dart';
import '../../domain/usecases/dispose_voice_recorder_usecase.dart';
import '../../domain/usecases/get_voice_recording_amplitude_usecase.dart';
import '../../domain/usecases/parse_voice_transaction_usecase.dart';
import '../../domain/usecases/start_voice_recording_usecase.dart';
import '../../domain/usecases/stop_voice_recording_usecase.dart';
import '../controllers/voice_transaction_controller.dart';

class VoiceTransactionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VoiceAudioRecorderDataSource>()) {
      Get.lazyPut<VoiceAudioRecorderDataSource>(
        () => VoiceAudioRecorderDataSourceImpl(),
      );
    }
    if (!Get.isRegistered<VoiceTransactionRemoteDataSource>()) {
      Get.lazyPut<VoiceTransactionRemoteDataSource>(
        () => VoiceTransactionRemoteDataSourceImpl(),
      );
    }
    if (!Get.isRegistered<VoiceTransactionRepository>()) {
      Get.lazyPut<VoiceTransactionRepository>(
        () => VoiceTransactionRepositoryImpl(
          audioRecorderDataSource: Get.find(),
          remoteDataSource: Get.find(),
        ),
      );
    }
    if (!Get.isRegistered<StartVoiceRecordingUseCase>()) {
      Get.lazyPut(
        () => StartVoiceRecordingUseCase(repository: Get.find()),
      );
    }
    if (!Get.isRegistered<StopVoiceRecordingUseCase>()) {
      Get.lazyPut(
        () => StopVoiceRecordingUseCase(repository: Get.find()),
      );
    }
    if (!Get.isRegistered<CancelVoiceRecordingUseCase>()) {
      Get.lazyPut(
        () => CancelVoiceRecordingUseCase(repository: Get.find()),
      );
    }
    if (!Get.isRegistered<ParseVoiceTransactionUseCase>()) {
      Get.lazyPut(
        () => ParseVoiceTransactionUseCase(repository: Get.find()),
      );
    }
    if (!Get.isRegistered<DisposeVoiceRecorderUseCase>()) {
      Get.lazyPut(
        () => DisposeVoiceRecorderUseCase(repository: Get.find()),
      );
    }
    if (!Get.isRegistered<GetVoiceRecordingAmplitudeUseCase>()) {
      Get.lazyPut(
        () => GetVoiceRecordingAmplitudeUseCase(repository: Get.find()),
      );
    }
    if (!Get.isRegistered<VoiceTransactionController>()) {
      Get.lazyPut(
        () => VoiceTransactionController(
          startVoiceRecordingUseCase: Get.find(),
          stopVoiceRecordingUseCase: Get.find(),
          cancelVoiceRecordingUseCase: Get.find(),
          parseVoiceTransactionUseCase: Get.find(),
          disposeVoiceRecorderUseCase: Get.find(),
          getVoiceRecordingAmplitudeUseCase: Get.find(),
        ),
      );
    }
  }
}
