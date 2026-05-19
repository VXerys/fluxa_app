import 'package:get/get.dart';

import '../../../transaction/presentation/bindings/transaction_binding.dart';
import '../controllers/main_navigation_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    TransactionBinding().dependencies();
    Get.lazyPut(() => MainNavigationController());
  }
}
