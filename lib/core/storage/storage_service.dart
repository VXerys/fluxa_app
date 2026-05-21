import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _box = GetStorage();

  static Future<void> init() async {
    await GetStorage.init();
  }

  static T? read<T>(String key) {
    final v = _box.read(key);
    if (v == null) return null;
    return v as T;
  }

  static Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  static Future<void> remove(String key) async {
    await _box.remove(key);
  }

  static Future<void> clear() async {
    await _box.erase();
  }

  static Future<void> clearExcept(Set<String> preservedKeys) async {
    final keys = _box.getKeys().toList();
    for (final key in keys) {
      final asString = key.toString();
      if (preservedKeys.contains(asString)) {
        continue;
      }
      await _box.remove(asString);
    }
  }
}
