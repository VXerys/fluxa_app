import 'package:get/get.dart';

import '../../../../core/sync/finance_sync_service.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../domain/usecases/get_home_summary_usecase.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GetHomeSummaryUseCase>()) {
      Get.lazyPut(
        () => GetHomeSummaryUseCase(
          transactionRepository: Get.find<TransactionRepository>(),
          walletRepository: Get.find<WalletRepository>(),
        ),
      );
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut(
        () => HomeController(
          getHomeSummaryUseCase: Get.find(),
          financeSyncService: Get.find<FinanceSyncService>(),
        ),
      );
    }
  }
}
