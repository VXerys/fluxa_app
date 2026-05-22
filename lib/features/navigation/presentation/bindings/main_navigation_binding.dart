import 'package:get/get.dart';

import '../../../home/presentation/bindings/home_binding.dart';
import '../../../profile/presentation/bindings/profile_binding.dart';
import '../../../statistics/presentation/bindings/statistics_binding.dart';
import '../../../transaction/presentation/bindings/transaction_binding.dart';
import '../../../wallet/presentation/bindings/wallet_binding.dart';
import '../controllers/main_navigation_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    WalletBinding().dependencies();
    TransactionBinding().dependencies();
    HomeBinding().dependencies();
    ProfileBinding().dependencies();
    StatisticsBinding().dependencies();
    if (!Get.isRegistered<MainNavigationController>()) {
      Get.lazyPut(() => MainNavigationController());
    }
  }
}
