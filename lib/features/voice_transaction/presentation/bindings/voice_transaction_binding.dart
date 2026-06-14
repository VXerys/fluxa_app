import 'package:get/get.dart';

import '../../../transaction/data/datasources/category_remote_datasource.dart';
import '../../../transaction/data/datasources/transaction_remote_datasource.dart';
import '../../../transaction/data/repositories/category_repository_impl.dart';
import '../../../transaction/data/repositories/transaction_repository_impl.dart';
import '../../../transaction/domain/repositories/category_repository.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/domain/usecases/add_transaction_usecase.dart';
import '../../../transaction/domain/usecases/get_categories_usecase.dart';
import '../../../wallet/data/datasources/wallet_remote_datasource.dart';
import '../../../wallet/data/repositories/wallet_repository_impl.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallets_usecase.dart';
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
    if (!Get.isRegistered<CategoryRemoteDataSource>()) {
      Get.lazyPut<CategoryRemoteDataSource>(() => CategoryRemoteDataSourceImpl());
    }
    if (!Get.isRegistered<TransactionRemoteDataSource>()) {
      Get.lazyPut<TransactionRemoteDataSource>(
        () => TransactionRemoteDataSourceImpl(),
      );
    }
    if (!Get.isRegistered<CategoryRepository>()) {
      Get.lazyPut<CategoryRepository>(
        () => CategoryRepositoryImpl(remoteDataSource: Get.find()),
      );
    }
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut<TransactionRepository>(
        () => TransactionRepositoryImpl(remoteDataSource: Get.find()),
      );
    }
    if (!Get.isRegistered<GetCategoriesUseCase>()) {
      Get.lazyPut(() => GetCategoriesUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<AddTransactionUseCase>()) {
      Get.lazyPut(() => AddTransactionUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<WalletRemoteDataSource>()) {
      Get.lazyPut<WalletRemoteDataSource>(() => WalletRemoteDataSourceImpl());
    }
    if (!Get.isRegistered<WalletRepository>()) {
      Get.lazyPut<WalletRepository>(
        () => WalletRepositoryImpl(remoteDataSource: Get.find()),
      );
    }
    if (!Get.isRegistered<GetWalletsUseCase>()) {
      Get.lazyPut(() => GetWalletsUseCase(repository: Get.find()));
    }
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
          getCategoriesUseCase: Get.find(),
          getWalletsUseCase: Get.find(),
          addTransactionUseCase: Get.find(),
        ),
      );
    }
  }
}
