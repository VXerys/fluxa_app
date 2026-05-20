import 'package:get/get.dart';

import '../../../transaction/presentation/bindings/transaction_binding.dart';
import '../../domain/usecases/get_home_summary_usecase.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    TransactionBinding().dependencies();

    Get.lazyPut(() => GetHomeSummaryUseCase(repository: Get.find()));
    Get.lazyPut(() => HomeController(getHomeSummaryUseCase: Get.find()));
  }
}
