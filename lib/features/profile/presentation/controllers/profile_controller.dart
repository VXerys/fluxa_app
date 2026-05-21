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

  // Static list of card gradient themes shared across pages
  static const List<Map<String, dynamic>> cardThemes = [
    {'name': 'Biru Klasik', 'colors': [Color(0xFF4FACFE), Color(0xFF00F2FE)]},
    {'name': 'Pelangi', 'colors': [Color(0xFFFA709A), Color(0xFFFEE140)]},
    {'name': 'Laut Tosca', 'colors': [Color(0xFF00C6FB), Color(0xFF005BEA)]},
    {'name': 'Ungu Berry', 'colors': [Color(0xFF662D8C), Color(0xFFED1E79)]},
    {'name': 'Senja Jingga', 'colors': [Color(0xFFFF9A9E), Color(0xFFFECFE7)]},
    {'name': 'Aurora', 'colors': [Color(0xFF00C9FF), Color(0xFF92FE9D)]},
  ];

  final RxInt selectedThemeIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final savedIndex = StorageService.read<int>('selected_card_theme_index');
    if (savedIndex != null && savedIndex >= 0 && savedIndex < cardThemes.length) {
      selectedThemeIndex.value = savedIndex;
    }
  }

  void selectTheme(int index) {
    if (index >= 0 && index < cardThemes.length) {
      selectedThemeIndex.value = index;
      StorageService.write('selected_card_theme_index', index);
    }
  }

  Future<void> resetData() async {
    _isResetting.value = true;
    await StorageService.clear();
    await LocalDatabaseService.clearAll();
    // Re-initialize default card theme on clear
    selectedThemeIndex.value = 0;
    _isResetting.value = false;

    Get.snackbar(
      'Berhasil',
      'Data lokal/cache telah dihapus',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }
}
