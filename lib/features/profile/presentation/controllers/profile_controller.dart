import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/database/local_database_service.dart';
import 'package:fluxa_app/core/storage/storage_service.dart';

class ProfileController extends GetxController {
  final RxBool _isResetting = false.obs;
  bool get isResetting => _isResetting.value;

  final RxString _appVersion = '1.0.0'.obs;
  String get appVersion => _appVersion.value;

  Future<void> resetData() async {
    _isResetting.value = true;
    await StorageService.clear();
    await LocalDatabaseService.clearAll();
    _isResetting.value = false;

    Get.snackbar(
      'Berhasil',
      'Semua data lokal telah dihapus',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }
}
