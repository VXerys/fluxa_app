import 'package:get/get.dart';

import '../../../../core/sync/finance_sync_service.dart';
import '../../../transaction/data/datasources/transaction_remote_datasource.dart';
import '../../../transaction/data/repositories/transaction_repository_impl.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/archive_wallet_usecase.dart';
import '../../domain/usecases/create_wallet_usecase.dart';
import '../../domain/usecases/get_monthly_cashflow_comparison_usecase.dart';
import '../../domain/usecases/get_total_balance_usecase.dart';
import '../../domain/usecases/get_wallets_usecase.dart';
import '../../domain/usecases/update_wallet_usecase.dart';
import '../controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WalletRemoteDataSource>()) {
      Get.lazyPut<WalletRemoteDataSource>(() => WalletRemoteDataSourceImpl());
    }

    if (!Get.isRegistered<WalletRepository>()) {
      Get.lazyPut<WalletRepository>(
        () => WalletRepositoryImpl(remoteDataSource: Get.find()),
      );
    }
    if (!Get.isRegistered<TransactionRemoteDataSource>()) {
      Get.lazyPut<TransactionRemoteDataSource>(
        () => TransactionRemoteDataSourceImpl(),
      );
    }
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut<TransactionRepository>(
        () => TransactionRepositoryImpl(remoteDataSource: Get.find()),
      );
    }

    if (!Get.isRegistered<GetWalletsUseCase>()) {
      Get.lazyPut(() => GetWalletsUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<CreateWalletUseCase>()) {
      Get.lazyPut(() => CreateWalletUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<UpdateWalletUseCase>()) {
      Get.lazyPut(() => UpdateWalletUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<ArchiveWalletUseCase>()) {
      Get.lazyPut(() => ArchiveWalletUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<GetTotalBalanceUseCase>()) {
      Get.lazyPut(() => GetTotalBalanceUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<GetMonthlyCashflowComparisonUseCase>()) {
      Get.lazyPut(
        () => GetMonthlyCashflowComparisonUseCase(
          transactionRepository: Get.find(),
        ),
      );
    }

    if (!Get.isRegistered<WalletController>()) {
      Get.lazyPut(
        () => WalletController(
          getWalletsUseCase: Get.find(),
          createWalletUseCase: Get.find(),
          updateWalletUseCase: Get.find(),
          archiveWalletUseCase: Get.find(),
          getTotalBalanceUseCase: Get.find(),
          getMonthlyCashflowComparisonUseCase: Get.find(),
          financeSyncService: Get.find<FinanceSyncService>(),
        ),
      );
    }
  }
}
