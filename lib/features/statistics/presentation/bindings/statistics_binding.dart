import 'package:get/get.dart';

import '../../../../core/sync/finance_sync_service.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/usecases/get_statistics_usecase.dart';
import '../controllers/statistics_controller.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StatisticsRepository>()) {
      Get.lazyPut<StatisticsRepository>(
        () => StatisticsRepositoryImpl(
          transactionRepository: Get.find<TransactionRepository>(),
        ),
      );
    }
    if (!Get.isRegistered<GetStatisticsUseCase>()) {
      Get.lazyPut(() => GetStatisticsUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<StatisticsController>()) {
      Get.lazyPut(
        () => StatisticsController(
          getStatisticsUseCase: Get.find(),
          financeSyncService: Get.find<FinanceSyncService>(),
        ),
      );
    }
  }
}
