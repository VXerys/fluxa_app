import 'package:get/get.dart';

import 'package:fluxa_app/core/sync/finance_sync_service.dart';
import 'package:fluxa_app/features/profile/presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(
        () => ProfileController(financeSyncService: Get.find<FinanceSyncService>()),
      );
    }
  }
}
