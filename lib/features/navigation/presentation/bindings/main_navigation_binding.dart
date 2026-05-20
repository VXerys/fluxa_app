import 'package:get/get.dart';

import '../../../home/presentation/bindings/home_binding.dart';
import '../../../profile/presentation/bindings/profile_binding.dart';
import '../../../transaction/presentation/bindings/transaction_binding.dart';
import '../controllers/main_navigation_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    HomeBinding().dependencies();
    TransactionBinding().dependencies();
    ProfileBinding().dependencies();
    Get.lazyPut(() => MainNavigationController());
  }
}
