# fluxa_app 💸

> **Untuk AI Coding Assistant (GitHub Copilot / Cursor / dll):**
> Ini adalah **entry point** dokumentasi `fluxa_app`. Baca file ini terlebih dahulu, lalu navigasi ke dokumen spesifik sesuai konteks pekerjaan. **Semua keputusan arsitektur WAJIB mengikuti pola di ketiga file referensi: `struktur.md`, `struktur_core.md`, dan `struktur_feature.md`.**

---

## Navigasi Dokumentasi

| File | Isi |
|------|-----|
| **`README.md`** ← (kamu di sini) | Overview, tech stack, struktur folder, getting started |
| **[`docs/FEATURES.md`](docs/FEATURES.md)** | Detail semua fitur MVP, flow Freemium vs PRO, batasan tiap fitur |
| **[`docs/DATABASE.md`](docs/DATABASE.md)** | Skema Supabase, strategi `sqflite` sebagai cache & offline queue |
| **[`docs/TECHNICAL_GUIDELINES.md`](docs/TECHNICAL_GUIDELINES.md)** | Aturan arsitektur, Abstract Contract TBD (OCR, Voice, Exchange Rates) |

---

## 1. Tentang Aplikasi

**fluxa_app** adalah aplikasi pencatatan keuangan pribadi mobile-first yang dibangun dengan Flutter, dengan target rilis ke **Google Play Store**. Aplikasi ini menganut model **Freemium** — fitur inti tersedia gratis, fitur premium (tema, ikon, AI kuota lebih) tersedia setelah upgrade ke akun **PRO**.

### Filosofi Produk

- **Offline-First dengan Cloud Sync:** Pengguna bisa mencatat transaksi kapan saja tanpa koneksi. Data disinkronkan ke Supabase saat online.
- **AI-Assisted, Not AI-Dependent:** Fitur AI (Receipt Scanner, Voice Record) adalah akselerasi — bukan keharusan. Semua fitur tetap bisa dipakai manual.
- **Design System Konsisten:** Semua warna, spacing, dan tipografi mengacu pada `AppColors`, `AppSpacing`, dan `AppTextStyles` di `core/constants/`. Tidak ada nilai hardcode di widget.

---

## 2. Tech Stack

| Kategori | Teknologi | Keterangan |
|----------|-----------|------------|
| **UI Framework** | Flutter (stable channel) | Cross-platform, target Android & iOS |
| **State Management / DI / Routing** | GetX | Seluruh state, DI, dan navigasi menggunakan GetX |
| **Remote DB / Auth** | Supabase | PostgreSQL + Auth + Realtime + Storage |
| **Local DB** | `sqflite` | Cache transaksi & offline queue |
| **Local Storage (KV)** | `get_storage` | Token, preferensi user, tema aktif |
| **Arsitektur** | Clean Architecture + Feature-First | KETAT — lihat `struktur_feature.md` |
| **Error Handling** | `dartz` (`Either<Failure, T>`) | Semua UseCase menggunakan Either |
| **Logging** | `logger` | `AppLogger` dari `core/utils/logger.dart` |
| **Dependency Lazy** | GetX `lazyPut` | Setiap fitur punya Binding sendiri |

### Package yang Sudah Pasti Digunakan

```yaml
# pubspec.yaml (dependencies utama)
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  get_storage: ^2.1.1
  supabase_flutter: ^2.x.x
  sqflite: ^2.3.x
  path_provider: ^2.1.x
  dartz: ^0.10.1
  logger: ^2.x.x
  intl: ^0.19.x                  # Format mata uang & tanggal
  fl_chart: ^0.68.x              # Grafik statistik
  speech_to_text: ^6.x.x         # Voice Quick Record
  image_picker: ^1.x.x           # Receipt Scanner (ambil foto)
  csv: ^6.x.x                    # Export CSV
  excel: ^4.x.x                  # Export Excel
  pdf: ^3.x.x                    # Export PDF (on-device)
  printing: ^5.x.x               # Print/share PDF
```

### Package dengan Implementasi TBD (Abstraksi Wajib)

```yaml
  # OCR / Receipt Scanner — masih dievaluasi
  # Kandidat: google_mlkit_text_recognition, tesseract_ocr, atau API eksternal
  # → Wajib dibungkus Abstract Contract. Lihat TECHNICAL_GUIDELINES.md

  # LLM / AI Parsing — masih dievaluasi
  # Kandidat: OpenAI API, Gemini API, atau Mistral
  # → Wajib dibungkus Abstract Contract. Lihat TECHNICAL_GUIDELINES.md

  # Exchange Rate API — masih dievaluasi
  # Kandidat: exchangeratesapi.io, fixer.io, atau frankfurter.app (gratis)
  # → Wajib dibungkus Abstract Contract. Lihat TECHNICAL_GUIDELINES.md
```

---

## 3. Struktur Folder Lengkap

> Mengikuti **Feature-First + Clean Architecture** sesuai `struktur.md`. Setiap fitur mandiri dalam foldernya.

```text
fluxa_app/
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart          # Design token warna
│   │   │   ├── app_constants.dart       # Supabase URL, anonKey, config global
│   │   │   ├── app_spacing.dart         # Spacing, radius, shadow
│   │   │   └── app_text_styles.dart     # Tipografi (Inter font)
│   │   ├── di/
│   │   │   └── initial_binding.dart     # DI global (permanent)
│   │   ├── errors/
│   │   │   ├── exceptions.dart          # DataLayer exceptions
│   │   │   └── failures.dart            # Domain failures
│   │   ├── network/
│   │   │   └── supabase_client.dart     # Singleton Supabase
│   │   ├── routes/
│   │   │   ├── app_routes.dart          # String constants semua route
│   │   │   └── app_pages.dart           # GetPage mapping
│   │   ├── storage/
│   │   │   └── storage_service.dart     # GetStorage wrapper
│   │   ├── usecases/
│   │   │   └── usecase.dart             # Abstract base UseCase + NoParams
│   │   ├── utils/
│   │   │   ├── logger.dart              # AppLogger (pretty printer)
│   │   │   ├── currency_formatter.dart  # Format Rp / USD / dll
│   │   │   └── date_formatter.dart      # Format tanggal lokal
│   │   └── widgets/
│   │       ├── app_loading_widget.dart
│   │       ├── app_empty_state_widget.dart
│   │       └── app_error_widget.dart
│   │
│   └── features/
│       │
│       ├── auth/                        # Login, Register, Onboarding
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   └── auth_remote_datasource.dart
│       │   │   ├── models/
│       │   │   │   └── user_model.dart
│       │   │   └── repositories/
│       │   │       └── auth_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── user_entity.dart
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository.dart
│       │   │   └── usecases/
│       │   │       ├── sign_in_usecase.dart
│       │   │       ├── sign_up_usecase.dart
│       │   │       ├── sign_out_usecase.dart
│       │   │       └── get_current_user_usecase.dart
│       │   └── presentation/
│       │       ├── bindings/
│       │       │   └── auth_binding.dart
│       │       ├── controllers/
│       │       │   └── auth_controller.dart
│       │       ├── pages/
│       │       │   ├── onboarding_page.dart
│       │       │   ├── login_page.dart
│       │       │   └── register_page.dart
│       │       └── widgets/
│       │
│       ├── home/                        # Dashboard utama (Saldo, Transaksi Terakhir, Menu)
│       │   ├── domain/
│       │   │   └── usecases/
│       │   │       └── get_home_summary_usecase.dart
│       │   └── presentation/
│       │       ├── bindings/
│       │       │   └── home_binding.dart
│       │       ├── controllers/
│       │       │   └── home_controller.dart
│       │       ├── pages/
│       │       │   └── home_page.dart
│       │       └── widgets/
│       │           ├── balance_card_widget.dart
│       │           ├── quick_menu_widget.dart
│       │           └── recent_transactions_widget.dart
│       │
│       ├── transaction/                 # CRUD Transaksi (Pemasukan / Pengeluaran / Transfer)
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── transaction_remote_datasource.dart
│       │   │   │   └── transaction_local_datasource.dart  # sqflite offline queue
│       │   │   ├── models/
│       │   │   │   └── transaction_model.dart
│       │   │   └── repositories/
│       │   │       └── transaction_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── transaction_entity.dart
│       │   │   ├── repositories/
│       │   │   │   └── transaction_repository.dart
│       │   │   └── usecases/
│       │   │       ├── add_transaction_usecase.dart
│       │   │       ├── update_transaction_usecase.dart
│       │   │       ├── delete_transaction_usecase.dart
│       │   │       ├── get_transactions_usecase.dart
│       │   │       └── sync_offline_queue_usecase.dart
│       │   └── presentation/
│       │       ├── bindings/
│       │       │   └── transaction_binding.dart
│       │       ├── controllers/
│       │       │   └── transaction_controller.dart
│       │       ├── pages/
│       │       │   ├── add_transaction_page.dart
│       │       │   └── transaction_list_page.dart
│       │       └── widgets/
│       │
│       ├── statistics/                  # Grafik & analisis (Mingguan, Bulanan, Tahunan)
│       │   ├── data/ ...
│       │   ├── domain/ ...
│       │   └── presentation/
│       │       ├── pages/
│       │       │   └── statistics_page.dart
│       │       └── widgets/
│       │           ├── period_tab_widget.dart
│       │           ├── income_expense_toggle_widget.dart
│       │           └── daily_summary_widget.dart
│       │
│       ├── wallet/                      # Dompet (Cash, Bank, E-Wallet)
│       │   ├── data/ ...
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── wallet_entity.dart
│       │   │   └── usecases/
│       │   │       ├── get_wallets_usecase.dart
│       │   │       ├── add_wallet_usecase.dart
│       │   │       └── update_wallet_balance_usecase.dart
│       │   └── presentation/
│       │       ├── pages/
│       │       │   └── wallet_page.dart
│       │       └── widgets/
│       │           └── wallet_card_widget.dart
│       │
│       ├── receipt_scanner/             # AI Receipt Scanner (OCR)
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── ocr_datasource.dart           # Abstract Contract
│       │   │   │   └── ocr_datasource_impl.dart      # Implementasi aktif (swap-able)
│       │   │   └── repositories/
│       │   │       └── receipt_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── scanned_receipt_entity.dart
│       │   │   ├── repositories/
│       │   │   │   └── receipt_repository.dart
│       │   │   └── usecases/
│       │   │       ├── scan_receipt_usecase.dart
│       │   │       └── check_scan_quota_usecase.dart
│       │   └── presentation/
│       │       ├── bindings/
│       │       │   └── receipt_scanner_binding.dart
│       │       ├── controllers/
│       │       │   └── receipt_scanner_controller.dart
│       │       └── pages/
│       │           └── receipt_scanner_page.dart
│       │
│       ├── voice_record/                # Voice Quick Record
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── voice_intent_datasource.dart       # Abstract Contract
│       │   │   │   └── voice_intent_datasource_impl.dart  # LLM API (swap-able)
│       │   │   └── repositories/
│       │   │       └── voice_record_repository_impl.dart
│       │   ├── domain/ ...
│       │   └── presentation/ ...
│       │
│       ├── budget/                      # Anggaran per kategori
│       │   └── ...
│       │
│       ├── recurring/                   # Transaksi berulang otomatis
│       │   └── ...
│       │
│       ├── savings_goal/                # Target Tabungan
│       │   └── ...
│       │
│       ├── currency/                    # Currency Picker & Live Exchange Rates
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── exchange_rate_datasource.dart       # Abstract Contract
│       │   │   │   ├── exchange_rate_remote_datasource_impl.dart
│       │   │   │   └── exchange_rate_local_datasource.dart # sqflite cache harian
│       │   │   └── repositories/
│       │   │       └── currency_repository_impl.dart
│       │   ├── domain/ ...
│       │   └── presentation/ ...
│       │
│       ├── export/                      # Export CSV / Excel / PDF
│       │   └── ...
│       │
│       ├── smart_notes/                 # Catatan pintar per transaksi
│       │   └── ...
│       │
│       ├── premium/                     # Manajemen langganan PRO
│       │   └── ...
│       │
│       ├── theme/                       # Tema, Ikon, Kustomisasi Visual
│       │   └── ...
│       │
│       ├── profile/                     # Profil, Preferensi, Pengaturan
│       │   └── ...
│       │
│       └── navigation/                  # Bottom navigation shell
│           └── presentation/
│               ├── bindings/
│               │   └── main_navigation_binding.dart
│               ├── controllers/
│               │   └── main_navigation_controller.dart
│               └── pages/
│                   └── main_navigation_page.dart
│
├── assets/
│   ├── fonts/
│   │   └── Inter/                       # Inter font (Regular, Medium, SemiBold, Bold)
│   ├── images/
│   ├── icons/
│   │   ├── free/                        # Icon pack gratis
│   │   └── premium/                     # Icon pack PRO (terkunci)
│   └── themes/
│       ├── free/                        # Tema gratis (Klasik, Samudra)
│       └── premium/                     # Tema PRO (Seaside PRO, Neon Fever, dll)
│
├── docs/
│   ├── FEATURES.md
│   ├── DATABASE.md
│   └── TECHNICAL_GUIDELINES.md
│
├── test/
│   ├── unit/
│   └── widget/
│
├── pubspec.yaml
└── README.md
```

---

## 4. Getting Started

### 4.1 Prasyarat

```bash
# Flutter stable channel
flutter channel stable
flutter upgrade

# Cek environment
flutter doctor
```

### 4.2 Clone & Setup

```bash
git clone <repo-url> fluxa_app
cd fluxa_app

# Install dependencies
flutter pub get

# Salin template env
cp .env.example .env
```

### 4.3 Konfigurasi Supabase

Buka `lib/core/constants/app_constants.dart` dan isi:

```dart
class AppConstants {
  static const String supabaseUrl  = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  static const String appName      = 'Fluxa';

  // Batas fitur Free tier
  static const int freeReceiptScanQuota = 5;   // per bulan
  static const int freeVoiceRecordQuota = 20;  // per bulan
}
```

### 4.4 Urutan Inisialisasi di `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Local storage (GetStorage) — selalu pertama
  await StorageService.init();

  // 2. Local database (sqflite)
  await LocalDatabaseService.init();

  // 3. Backend client (Supabase)
  await SupabaseService.initialize();

  // 4. Cek state awal
  final hasSeenOnboarding = StorageService.read<bool>('has_seen_onboarding') ?? false;
  final isLoggedIn = StorageService.getAccessToken() != null;

  runApp(FluxaApp(
    initialRoute: _resolveInitialRoute(hasSeenOnboarding, isLoggedIn),
  ));
}

String _resolveInitialRoute(bool hasSeenOnboarding, bool isLoggedIn) {
  if (!hasSeenOnboarding) return Routes.onboarding;
  if (!isLoggedIn) return Routes.login;
  return Routes.main;
}
```

### 4.5 Jalankan Aplikasi

```bash
# Debug mode
flutter run

# Release build (untuk Play Store)
flutter build apk --release
flutter build appbundle --release   # Disarankan untuk Play Store
```

---

## 5. Navigasi Aplikasi (Bottom Nav)

Berdasarkan UI, terdapat 5 tab utama:

| Tab | Route | Halaman |
|-----|-------|---------|
| 🏠 Home | `/main/home` | Saldo total, menu shortcut, transaksi terakhir |
| 📈 Statistik | `/main/statistics` | Grafik pemasukan/pengeluaran, ringkasan harian |
| 👛 Dompet | `/main/wallet` | Daftar akun (Cash, Bank, E-Wallet), total saldo |
| 👤 Profil | `/main/profile` | Pengaturan, tema, export, upgrade PRO |
| ➕ Tambah | (Bottom Sheet) | Quick add transaksi (income/expense/transfer) |

---

## 6. Sistem Freemium (PRO vs Free)

| Fitur | Free | PRO |
|-------|------|-----|
| Pencatatan transaksi | ✅ Unlimited | ✅ Unlimited |
| Receipt Scanner | ✅ 5x/bulan | ✅ Unlimited |
| Voice Quick Record | ✅ 20x/bulan | ✅ Unlimited |
| Tema visual | ✅ 2 tema dasar | ✅ Semua tema |
| Icon Pack | ✅ Default | ✅ Semua pack |
| Urutan Menu Kustom | ❌ | ✅ |
| Export data (CSV/Excel/PDF) | ✅ CSV only | ✅ Semua format |
| Cloud Backup | ✅ | ✅ Priority sync |
| Iklan | ✅ (ada) | ❌ (bebas iklan) |

---

*Dokumen ini adalah entry point. Lanjut ke [`docs/FEATURES.md`](docs/FEATURES.md) untuk detail fitur.*
