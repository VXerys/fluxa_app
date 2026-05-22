import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/database/local_database_service.dart';
import 'package:fluxa_app/core/sync/finance_sync_service.dart';
import 'package:fluxa_app/core/storage/storage_service.dart';

class HomeMenuDefinition {
  final String id;
  final String label;
  final AppIconData icon;
  final String actionKey;

  const HomeMenuDefinition({
    required this.id,
    required this.label,
    required this.icon,
    required this.actionKey,
  });
}

class MenuColorPalette {
  final String name;
  final List<Color> colors;

  const MenuColorPalette({required this.name, required this.colors});
}

class ProfileController extends GetxController {
  final FinanceSyncService financeSyncService;

  ProfileController({required this.financeSyncService});

  static const String _selectedCardThemeStorageKey = 'selected_card_theme_index';
  static const String _selectedMenuPaletteStorageKey =
      'selected_menu_palette_index';
  static const String _menuOrderStorageKey = 'home_menu_order';

  final RxBool _isResetting = false.obs;
  bool get isResetting => _isResetting.value;

  final RxString _appVersion = '1.0.0'.obs;
  String get appVersion => _appVersion.value;

  // Static list of card gradient themes shared across pages.
  static const List<Map<String, dynamic>> cardThemes = [
    {'name': 'Biru Klasik', 'colors': [Color(0xFF4FACFE), Color(0xFF00F2FE)]},
    {'name': 'Pelangi', 'colors': [Color(0xFFFA709A), Color(0xFFFEE140)]},
    {'name': 'Samudra', 'colors': [Color(0xFF00C6FB), Color(0xFF005BEA)]},
    {'name': 'Ungu Berry', 'colors': [Color(0xFF662D8C), Color(0xFFED1E79)]},
    {'name': 'Senja', 'colors': [Color(0xFFFFA751), Color(0xFFFF5F6D)]},
    {'name': 'Aurora', 'colors': [Color(0xFF00C9FF), Color(0xFF92FE9D)]},
    {'name': 'Hutan', 'colors': [Color(0xFF4CAF50), Color(0xFF8BC34A)]},
    {'name': 'Pastel', 'colors': [Color(0xFFFFC3A0), Color(0xFFFFAFBD)]},
  ];

  static const List<HomeMenuDefinition> homeMenus = [
    HomeMenuDefinition(
      id: 'catat',
      label: 'Catat',
      icon: AppHugeIcons.add_circle_outline,
      actionKey: 'add_transaction',
    ),
    HomeMenuDefinition(
      id: 'riwayat',
      label: 'Riwayat',
      icon: AppHugeIcons.history,
      actionKey: 'transaction_list',
    ),
    HomeMenuDefinition(
      id: 'suara',
      label: 'Suara',
      icon: AppHugeIcons.mic_none,
      actionKey: 'voice_placeholder',
    ),
    HomeMenuDefinition(
      id: 'kartu',
      label: 'Kartu',
      icon: AppHugeIcons.credit_card_outlined,
      actionKey: 'card_placeholder',
    ),
  ];

  static const List<MenuColorPalette> menuColorPalettes = [
    MenuColorPalette(
      name: 'Klasik',
      colors: [
        Color(0xFFFF9800),
        Color(0xFF2196F3),
        Color(0xFF4CAF50),
        Color(0xFFF44336),
      ],
    ),
    MenuColorPalette(
      name: 'Samudra',
      colors: [
        Color(0xFF00BCD4),
        Color(0xFF2196F3),
        Color(0xFF009688),
        Color(0xFF607D8B),
      ],
    ),
    MenuColorPalette(
      name: 'Senja',
      colors: [
        Color(0xFFFF9800),
        Color(0xFFFFC107),
        Color(0xFFFBC02D),
        Color(0xFFFF5722),
      ],
    ),
    MenuColorPalette(
      name: 'Hutan',
      colors: [
        Color(0xFF4CAF50),
        Color(0xFF7B8D00),
        Color(0xFFA4B42B),
        Color(0xFF795548),
      ],
    ),
    MenuColorPalette(
      name: 'Permen',
      colors: [
        Color(0xFFFF6B6B),
        Color(0xFF4ECDC4),
        Color(0xFFF7E36D),
        Color(0xFFFF8FA3),
      ],
    ),
    MenuColorPalette(
      name: 'Neon',
      colors: [
        Color(0xFFEA00FF),
        Color(0xFF00E5FF),
        Color(0xFF00E676),
        Color(0xFFFF1744),
      ],
    ),
    MenuColorPalette(
      name: 'Pastel',
      colors: [
        Color(0xFFF8BBD0),
        Color(0xFFBBDEFB),
        Color(0xFFC8E6C9),
        Color(0xFFFFE0B2),
      ],
    ),
  ];

  static const List<String> _defaultMenuOrder = [
    'catat',
    'riwayat',
    'suara',
    'kartu',
  ];

  final RxInt selectedThemeIndex = 0.obs;
  final RxInt selectedMenuPaletteIndex = 0.obs;
  final RxList<String> _orderedHomeMenuIds = <String>[].obs;

  List<String> get orderedHomeMenuIds => List<String>.unmodifiable(
    _orderedHomeMenuIds,
  );

  List<HomeMenuDefinition> get orderedHomeMenus {
    final Map<String, HomeMenuDefinition> byId = {
      for (final HomeMenuDefinition item in homeMenus) item.id: item,
    };

    final List<HomeMenuDefinition> ordered = <HomeMenuDefinition>[];
    for (final String id in _orderedHomeMenuIds) {
      final HomeMenuDefinition? menu = byId[id];
      if (menu != null) {
        ordered.add(menu);
      }
    }

    if (ordered.length == homeMenus.length) {
      return ordered;
    }

    return homeMenus;
  }

  MenuColorPalette get selectedMenuPalette =>
      menuColorPalettes[selectedMenuPaletteIndex.value];

  @override
  void onInit() {
    super.onInit();
    final int? savedThemeIndex =
        StorageService.read<int>(_selectedCardThemeStorageKey);
    if (savedThemeIndex != null &&
        savedThemeIndex >= 0 &&
        savedThemeIndex < cardThemes.length) {
      selectedThemeIndex.value = savedThemeIndex;
    }

    final int? savedPaletteIndex =
        StorageService.read<int>(_selectedMenuPaletteStorageKey);
    if (savedPaletteIndex != null &&
        savedPaletteIndex >= 0 &&
        savedPaletteIndex < menuColorPalettes.length) {
      selectedMenuPaletteIndex.value = savedPaletteIndex;
    }

    final List<dynamic>? storedOrder =
        StorageService.read<List<dynamic>>(_menuOrderStorageKey);
    final List<String> parsedOrder = storedOrder == null
        ? _defaultMenuOrder
        : storedOrder
              .map((dynamic e) => e.toString())
              .where((String e) => e.isNotEmpty)
              .toList(growable: false);

    if (_isValidMenuOrder(parsedOrder)) {
      _orderedHomeMenuIds.assignAll(parsedOrder);
    } else {
      _orderedHomeMenuIds.assignAll(_defaultMenuOrder);
    }
  }

  void selectTheme(int index) {
    if (index >= 0 && index < cardThemes.length) {
      selectedThemeIndex.value = index;
      StorageService.write(_selectedCardThemeStorageKey, index);
    }
  }

  void selectMenuPalette(int index) {
    if (index >= 0 && index < menuColorPalettes.length) {
      selectedMenuPaletteIndex.value = index;
      StorageService.write(_selectedMenuPaletteStorageKey, index);
    }
  }

  void updateHomeMenuOrder(List<String> newOrder) {
    if (!_isValidMenuOrder(newOrder)) {
      return;
    }

    _orderedHomeMenuIds.assignAll(newOrder);
    StorageService.write(_menuOrderStorageKey, newOrder);
  }

  Color menuAccentColorAt(int index) {
    final List<Color> colors = selectedMenuPalette.colors;
    return colors[index % colors.length];
  }

  Color menuBgColorAt(int index) {
    return menuAccentColorAt(index).withValues(alpha: 0.14);
  }

  bool _isValidMenuOrder(List<String> order) {
    if (order.length != _defaultMenuOrder.length) {
      return false;
    }

    final Set<String> defaults = _defaultMenuOrder.toSet();
    final Set<String> incoming = order.toSet();
    return defaults.length == incoming.length && defaults.containsAll(incoming);
  }

  Future<void> _resetMenuCustomization() async {
    selectedMenuPaletteIndex.value = 0;
    _orderedHomeMenuIds.assignAll(_defaultMenuOrder);
    await StorageService.write(_selectedMenuPaletteStorageKey, 0);
    await StorageService.write(_menuOrderStorageKey, _defaultMenuOrder);
  }

  Future<void> _resetCardTheme() async {
    selectedThemeIndex.value = 0;
    await StorageService.write(_selectedCardThemeStorageKey, 0);
  }

  Future<void> resetCustomization() async {
    await _resetCardTheme();
    await _resetMenuCustomization();
  }

  HomeMenuDefinition findMenuById(String id) {
    return homeMenus.firstWhere((HomeMenuDefinition menu) => menu.id == id);
  }

  int get menuCount => homeMenus.length;

  Future<void> resetData() async {
    if (_isResetting.value) return;
    _isResetting.value = true;
    try {
      final client = supabase.Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'Sesi login tidak ditemukan',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      // Cloud reset: keep profile + auth account, wipe app data.
      await client.from('transactions').delete().eq('user_id', userId);
      await client.from('wallets').delete().eq('user_id', userId);
      await client
          .from('categories')
          .delete()
          .eq('user_id', userId)
          .eq('is_system', false);

      await LocalDatabaseService.clearAll();

      await StorageService.clearExcept(<String>{
        'access_token',
        'refresh_token',
        'user_id',
        'is_logged_in',
      });

      await resetCustomization();
      financeSyncService.emit(
        FinanceSyncEventType.dataReset,
        source: 'profile.reset',
      );

      Get.snackbar(
        'Berhasil',
        'Seluruh data aplikasi berhasil dihapus. Akun dan profil tetap aman.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } on supabase.PostgrestException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      _isResetting.value = false;
    }
  }
}




