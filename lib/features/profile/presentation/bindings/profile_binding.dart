import 'package:get/get.dart';

import 'package:fluxa_app/features/profile/presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
