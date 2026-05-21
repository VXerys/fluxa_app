import 'package:get/get.dart';

import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/archive_wallet_usecase.dart';
import '../../domain/usecases/create_wallet_usecase.dart';
import '../../domain/usecases/get_total_balance_usecase.dart';
import '../../domain/usecases/get_wallets_usecase.dart';
import '../../domain/usecases/update_wallet_usecase.dart';
import '../controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletRemoteDataSource>(() => WalletRemoteDataSourceImpl());

    Get.lazyPut<WalletRepository>(
      () => WalletRepositoryImpl(remoteDataSource: Get.find()),
    );

    Get.lazyPut(() => GetWalletsUseCase(repository: Get.find()));
    Get.lazyPut(() => CreateWalletUseCase(repository: Get.find()));
    Get.lazyPut(() => UpdateWalletUseCase(repository: Get.find()));
    Get.lazyPut(() => ArchiveWalletUseCase(repository: Get.find()));
    Get.lazyPut(() => GetTotalBalanceUseCase(repository: Get.find()));

    Get.lazyPut(
      () => WalletController(
        getWalletsUseCase: Get.find(),
        createWalletUseCase: Get.find(),
        updateWalletUseCase: Get.find(),
        archiveWalletUseCase: Get.find(),
        getTotalBalanceUseCase: Get.find(),
      ),
    );
  }
}
