# 🧱 Core Layer — `lib/core/`

> Berisi kode-kode **fondasi** yang digunakan di seluruh fitur. File-file di sini **tidak boleh** mengimport apapun dari `lib/features/` (kecuali `di/initial_binding.dart` yang memang tugasnya menghubungkan semuanya).

---

## 1. `core/errors/failures.dart` — Failure Classes (Domain Layer Error)

Failure adalah representasi error yang **aman untuk Domain & Presentation**. Tidak mengandung detail teknis seperti stack trace.

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
```

**Aturan:**
- `abstract class Failure` adalah base class. Setiap tipe error spesifik punya subclass sendiri.
- **Kapan pakai apa:**
  - `ServerFailure` → Error dari API/Backend (500, 400, dsb).
  - `CacheFailure` → Error dari local storage.
  - `NetworkFailure` → Tidak ada koneksi internet.
  - `AuthFailure` → Masalah autentikasi (token expired, unauthorized).
- Buat subclass baru sesuai kebutuhan (misal: `ValidationFailure`, `PermissionFailure`).

---

## 2. `core/errors/exceptions.dart` — Exception Classes (Data Layer Error)

Exception dilempar (throw) di Data Layer (DataSource). Kemudian di-*catch* di Repository dan dikonversi menjadi `Failure`.

```dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
```

**Hubungan Exception ↔ Failure:**
```text
DataSource throws ServerException
       ↓
Repository catches → returns Left(ServerFailure(...))
       ↓
Controller receives Either<Failure, Data> → handles UI feedback
```

---

## 3. `core/usecases/usecase.dart` — Base UseCase Contract

Ini adalah **abstract class generik** yang menjadi fondasi semua UseCase di seluruh fitur.

```dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
```

**Penjelasan:**
- `Type` → Tipe data yang dikembalikan jika **sukses** (misal: `BookEntity`, `List<BookEntity>`, `void`).
- `Params` → Tipe parameter input (misal: `CreateBookParams`). Jika tidak butuh parameter, gunakan `NoParams`.
- `Either<Failure, Type>` → Pattern dari package `dartz`. `Left` = error (`Failure`), `Right` = sukses (`Type`).
- Setiap UseCase di fitur **wajib** meng-extend atau meng-implement class ini.

**Package yang dibutuhkan di `pubspec.yaml`:**
```yaml
dependencies:
  dartz: ^0.10.1
```

---

## 4. `core/network/supabase_client.dart` — Backend Client Service

Singleton pattern untuk inisialisasi dan akses backend client.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase client not initialized');
    }
    return _client!;
  }
}
```

**Aturan:**
- `initialize()` dipanggil **sekali saja** di `main.dart` sebelum `runApp()`.
- Seluruh DataSource mengakses client via `SupabaseService.client`.
- Jika menggunakan **Dio** sebagai HTTP client, ganti file ini dengan `DioClient` yang berisi base URL, interceptors, dan token refresh logic.

---

## 5. `core/storage/storage_service.dart` — Local Storage

Wrapper statis untuk `GetStorage` (atau `SharedPreferences`). Menyederhanakan read/write agar konsisten di seluruh app.

```dart
import 'package:get_storage/get_storage.dart';

class StorageService {
  static final _storage = GetStorage();

  // === Key Constants (private) ===
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _isFirstTimeKey = 'is_first_time';

  // === Initialize ===
  static Future<void> init() async {
    await GetStorage.init();
  }

  // === Token Methods ===
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(_accessTokenKey, accessToken);
    await _storage.write(_refreshTokenKey, refreshToken);
  }

  static String? getAccessToken() =>
      _storage.read<String>(_accessTokenKey);

  static String? getRefreshToken() =>
      _storage.read<String>(_refreshTokenKey);

  static Future<void> clearTokens() async {
    await _storage.remove(_accessTokenKey);
    await _storage.remove(_refreshTokenKey);
  }

  // === User ID Methods ===
  static Future<void> saveUserId(String userId) async {
    await _storage.write(_userIdKey, userId);
  }

  static String? getUserId() =>
      _storage.read<String>(_userIdKey);

  // === Clear All ===
  static Future<void> clearAll() async {
    await _storage.erase();
  }

  // === Generic Read/Write ===
  static Future<void> write(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  static T? read<T>(String key) =>
      _storage.read<T>(key);

  static Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  // === Onboarding / First Time ===
  static bool isFirstTime() =>
      _storage.read<bool>(_isFirstTimeKey) ?? true;

  static Future<void> setFirstTimeComplete() async {
    await _storage.write(_isFirstTimeKey, false);
  }
}
```

**Aturan:**
- `init()` dipanggil di `main.dart` **sebelum** backend client.
- Semua key disimpan sebagai `static const String` di dalam class (private).
- Berikan method khusus untuk data penting (token, userId) agar tidak typo key.
- Method `write/read/remove` generik untuk kebutuhan ad-hoc di controller.

---

## 6. `core/constants/` — Design Tokens & App Config

### `app_constants.dart`
```dart
class AppConstants {
  static const String supabaseUrl = 'https://xxx.supabase.co';
  static const String supabaseAnonKey = 'sb_key_xxx';
  static const String appName = 'MyApp';
  // Tambahan: API timeout, pagination limit, dll.
}
```

### `app_colors.dart`
```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor → mencegah instansiasi

  static const Color primary = Color(0xFF3B6FF5);
  static const Color primaryLight = Color(0xFFE8EEFE);
  static const Color accent = Color(0xFFFF7F14);
  // ... semua warna dari design system / Figma
}
```

### `app_text_styles.dart`
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Konvensi nama: [font][size]w[weight][ColorName(jika bukan default)]
  static const TextStyle inter24w500 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.24,
    color: AppColors.black,
  );

  static const TextStyle inter14w400Secondary = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.14,
    color: AppColors.transparentBlack50, // Secondary color → masuk di nama
  );
}
```

### `app_spacing.dart`
```dart
import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // === Spacing Values ===
  static const double xxs = 4.0;
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;

  // === Border Radius ===
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);

  // === Reusable Shadows ===
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 30),
  ];
}
```

**Aturan constants:**
- Semua class menggunakan **private constructor** (`ClassName._()`) agar tidak bisa di-instansiasi.
- Semua member adalah `static const` (atau `static final` untuk objek non-const seperti `BorderRadius`).
- Jangan hardcode warna, spacing, atau style di widget — selalu referensi dari sini.

---

## 7. `core/routes/` — Routing & Navigation

### `app_routes.dart` — Daftar Nama Route (String Constants)
```dart
class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String bookDetail = '/book-detail/:bookId'; // Dynamic param
  // ... semua route
}
```

### `app_pages.dart` — Mapping Route → Page + Binding
```dart
import 'package:get/get.dart';
import 'app_routes.dart';
// ... import semua page & binding

class AppPages {
  static const initial = Routes.onboarding;

  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(), // Auto-inject dependencies saat halaman dibuka
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBinding(), // Composite binding untuk semua tab
    ),
    GetPage(
      name: Routes.bookDetail,
      page: () => const BookDetailPage(),
      binding: BookDetailBinding(),
      preventDuplicates: false, // Izinkan buka detail bertumpuk
    ),
    // ... semua GetPage
  ];
}
```

**Aturan routing:**
- Setiap `GetPage` **wajib** punya `binding` kecuali halaman statis tanpa controller.
- Untuk route dengan parameter dinamis, gunakan format `:paramName` (misal: `/book-detail/:bookId`).
- `preventDuplicates: false` jika halaman yang sama boleh dibuka berkali-kali (misal: detail page).

---

## 8. `core/di/initial_binding.dart` — Global Dependency Injection

Digunakan untuk dependency yang **harus hidup sepanjang siklus aplikasi** (permanent).

```dart
import 'package:get/get.dart';
// ... import datasource, repository, usecase, controller yang global

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core DataSource (permanent)
    Get.put<BookRemoteDataSource>(BookRemoteDataSourceImpl(), permanent: true);

    // Core Repository (permanent)
    Get.put<BookRepository>(
      BookRepositoryImpl(remoteDataSource: Get.find<BookRemoteDataSource>()),
      permanent: true,
    );

    // Global UseCases (permanent)
    Get.put(GetBookmarkedIdsUseCase(Get.find<BookRepository>()), permanent: true);
    Get.put(ToggleBookmarkUseCase(Get.find<BookRepository>()), permanent: true);

    // Global Controllers (permanent)
    Get.put(
      BookmarkController(
        getBookmarkedIdsUseCase: Get.find(),
        toggleBookmarkUseCase: Get.find(),
      ),
      permanent: true,
    );
  }
}
```

**Aturan `InitialBinding`:**
- Gunakan `Get.put(..., permanent: true)` → dependency ini TIDAK akan di-dispose.
- **Hanya** daftarkan yang benar-benar global (misal: auth state, bookmark state).
- Dependency per-fitur didaftarkan di **Binding masing-masing fitur**, bukan di sini.

---

## 9. `core/utils/logger.dart` — Logging Utility

```dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(dynamic message) => _logger.d(message);
  static void info(dynamic message) => _logger.i(message);
  static void warning(dynamic message) => _logger.w(message);
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
```

**Gunakan di DataSource/Repository/Controller:**
```dart
AppLogger.info('Books loaded: ${books.length}');
AppLogger.error('Failed to fetch', e, stackTrace);
```

---

> 📄 **Lanjut ke:** [`struktur_feature.md`](struktur_feature.md) untuk detail penulisan kode setiap layer di dalam fitur.
