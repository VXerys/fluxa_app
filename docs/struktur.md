# 📁 Struktur Folder & Arsitektur — Flutter Clean Architecture + GetX

> **Dokumen ini adalah template acuan** untuk membangun project Flutter baru dengan arsitektur **Feature-First + Clean Architecture** dan state management **GetX**.
> Dibagi menjadi 3 file:
> - **`struktur.md`** (ini) — Overview, folder tree, `main.dart`, routing, dan DI awal.
> - **`struktur_core.md`** — Detail semua file di `lib/core/` beserta contoh kode.
> - **`struktur_feature.md`** — Detail semua layer di `lib/features/` beserta contoh kode (Entity → Model → DataSource → Repository → UseCase → Binding → Controller).

---

## Struktur Folder Lengkap

```text
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_constants.dart
│   │   ├── app_spacing.dart
│   │   └── app_text_styles.dart
│   ├── di/
│   │   └── initial_binding.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── supabase_client.dart          # Bisa diganti Dio/HTTP client
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   ├── storage/
│   │   └── storage_service.dart
│   ├── usecases/
│   │   └── usecase.dart                  # Base abstract class UseCase
│   ├── utils/
│   │   └── logger.dart
│   └── widgets/
│       └── (reusable global widgets)
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── bindings/
    │       ├── controllers/
    │       ├── pages/
    │       └── widgets/
    │
    ├── book/                              # (contoh fitur lengkap)
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── book_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── book_model.dart
    │   │   └── repositories/
    │   │       └── book_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── book_entity.dart
    │   │   ├── repositories/
    │   │   │   └── book_repository.dart   # Abstract class (contract)
    │   │   └── usecases/
    │   │       ├── create_book_usecase.dart
    │   │       ├── delete_book_usecase.dart
    │   │       ├── get_user_books_usecase.dart
    │   │       └── toggle_bookmark_usecase.dart
    │   └── presentation/
    │       ├── bindings/
    │       │   └── book_binding.dart
    │       ├── controllers/
    │       │   ├── book_controller.dart
    │       │   └── bookmark_controller.dart
    │       ├── pages/
    │       │   ├── book_list_page.dart
    │       │   └── book_detail_page.dart
    │       └── widgets/
    │           └── (widget spesifik fitur)
    │
    ├── navigation/                        # (fitur khusus: hanya presentation)
    │   └── presentation/
    │       ├── bindings/
    │       │   └── main_navigation_binding.dart
    │       ├── controllers/
    │       │   └── main_navigation_controller.dart
    │       └── pages/
    │           └── main_navigation_page.dart
    │
    ├── community/                         # (struktur sama seperti book)
    ├── event/
    ├── home/
    ├── notification/
    ├── onboarding/                        # (fitur sederhana: hanya presentation)
    ├── profile/
    ├── borrow_request/
    └── cart/
```

---

## `main.dart` — Entry Point Aplikasi

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constants/app_constants.dart';
import 'core/di/initial_binding.dart';
import 'core/network/supabase_client.dart';
import 'core/storage/storage_service.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi local storage (GetStorage/SharedPreferences)
  await StorageService.init();

  // 2. Inisialisasi backend client (Supabase/Firebase/Dio)
  await SupabaseService.initialize();

  // 3. Cek kondisi awal (onboarding, login status, dll)
  bool hasSeenOnboarding =
      StorageService.read<bool>('has_seen_onboarding') ?? false;

  runApp(
    MyApp(initialRoute: hasSeenOnboarding ? Routes.login : Routes.onboarding),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: InitialBinding(),   // DI global yang hidup sepanjang app
      initialRoute: initialRoute,
      getPages: AppPages.routes,          // Daftar semua route & binding
    );
  }
}
```

**Poin penting `main.dart`:**
- Urutan inisialisasi: `WidgetsFlutterBinding` → `StorageService` → `BackendClient`.
- `initialBinding`: Mendaftarkan dependency **global** yang harus hidup sepanjang siklus app (misal: `BookmarkController`).
- `initialRoute`: Ditentukan secara dinamis berdasarkan kondisi storage.

---

## Alur Data (Flow) Secara Keseluruhan

```text
┌─────────────────────────────────────────────────────────────┐
│ Page (UI) → Controller → UseCase → Repository → DataSource │
│                                     (contract)   (impl)    │
│                                     ↕                      │
│                                   Entity ←── Model         │
└─────────────────────────────────────────────────────────────┘

Arah Dependency:
  Presentation → Domain ← Data

Domain TIDAK PERNAH mengimport Presentation atau Data.
Data mengimport Domain (untuk implement contract & convert Model → Entity).
Presentation mengimport Domain (untuk memanggil UseCase & menggunakan Entity).
```

---

## Konvensi Penamaan File

| Jenis File | Format Nama | Contoh |
|---|---|---|
| Entity | `{nama}_entity.dart` | `book_entity.dart` |
| Model | `{nama}_model.dart` | `book_model.dart` |
| DataSource | `{nama}_remote_datasource.dart` | `book_remote_datasource.dart` |
| Repository (contract) | `{nama}_repository.dart` | `book_repository.dart` |
| Repository (impl) | `{nama}_repository_impl.dart` | `book_repository_impl.dart` |
| UseCase | `{aksi}_{nama}_usecase.dart` | `create_book_usecase.dart` |
| Binding | `{nama}_binding.dart` | `book_binding.dart` |
| Controller | `{nama}_controller.dart` | `book_controller.dart` |
| Page | `{nama}_page.dart` | `book_list_page.dart` |
| Widget | `{nama}_{deskripsi}.dart` | `book_detail_testimonials.dart` |

> Semua file menggunakan format **snake_case**.

---

## Kapan Fitur TIDAK Perlu Data & Domain Layer?

Tidak semua fitur memerlukan 3 layer lengkap. Gunakan penilaian ini:

| Kondisi | Struktur yang Dipakai |
|---|---|
| Fitur punya API call / business logic | `data/` + `domain/` + `presentation/` (lengkap) |
| Fitur sederhana (hanya UI + navigasi) | Hanya `presentation/` (contoh: `onboarding/`, `navigation/`) |
| Fitur yang re-use data dari fitur lain | Hanya `presentation/` + import UseCase dari fitur lain via Binding |

---

> 📄 **Lanjut ke:** [`struktur_core.md`](struktur_core.md) untuk detail kode setiap file di `lib/core/`.
