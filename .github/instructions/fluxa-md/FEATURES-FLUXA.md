# FEATURES.md — Spesifikasi Fitur MVP fluxa_app

> Kembali ke: [README.md](../README.md) | [DATABASE.md](DATABASE.md) | [TECHNICAL_GUIDELINES.md](TECHNICAL_GUIDELINES.md)

---

## Daftar Fitur MVP

1. [AI Receipt Scanner](#1-ai-receipt-scanner)
2. [Voice Quick Record](#2-voice-quick-record)
3. [Premium Themes, Icons & Menu Ordering](#3-premium-themes-icons--menu-ordering)
4. [Weekly / Period Statistics](#4-weekly--period-statistics)
5. [Full Local Backup & Offline Support](#5-full-local-backup--offline-support)
6. [Smart Notes](#6-smart-notes)
7. [Recurring Transactions](#7-recurring-transactions)
8. [Professional Currency Picker & Exchange Rates](#8-professional-currency-picker--exchange-rates)
9. [Export Data](#9-export-data)

---

## 1. AI Receipt Scanner

### Deskripsi
Pengguna memotret struk belanja menggunakan kamera atau memilih dari galeri. Sistem mengekstrak teks dari gambar (OCR), lalu AI mem-parsing teks tersebut menjadi data transaksi terstruktur (nominal, kategori, merchant, tanggal).

### Flow Lengkap

```
1. User tap tombol "Scan Struk" di FAB atau halaman tambah transaksi
2. Cek kuota scan (Free: 5x/bulan | PRO: unlimited)
   └── Jika kuota habis → tampilkan modal upgrade PRO, hentikan alur
3. Buka kamera / image picker
4. User ambil foto struk
5. Gambar dikompres (client-side, sebelum dikirim ke OCR)
6. Kirim gambar ke OCR service → terima raw text
7. Kirim raw text ke LLM API untuk parsing intent:
   → Ekstrak: nominal, kategori, merchant/toko, tanggal, mata uang
8. Tampilkan hasil parsing ke form tambah transaksi (pre-filled, bisa diedit user)
9. User konfirmasi / koreksi → simpan transaksi
10. Dekremen kuota scan bulanan user
```

### Batasan Freemium

```
FREE:
- Kuota: 5 scan per bulan (reset tiap tanggal 1)
- Indikator kuota tampil di halaman scanner: "Tersisa 3 dari 5 scan gratis bulan ini"
- Jika kuota = 0 → tombol scan disabled, tampilkan banner upgrade PRO

PRO:
- Unlimited scan
- Prioritas antrian pemrosesan (jika ada queue)
```

### Struktur Fitur (Clean Architecture)

```
features/receipt_scanner/
├── domain/
│   ├── entities/
│   │   └── scanned_receipt_entity.dart
│   │       → id, imageLocalPath, rawOcrText, parsedAmount,
│   │         parsedCategory, parsedMerchant, parsedDate, confidence
│   ├── repositories/
│   │   └── receipt_repository.dart        ← Abstract contract
│   └── usecases/
│       ├── scan_receipt_usecase.dart       ← Params: imagePath
│       ├── parse_receipt_usecase.dart      ← Params: rawOcrText
│       └── check_scan_quota_usecase.dart   ← NoParams
│
├── data/
│   ├── datasources/
│   │   ├── ocr_datasource.dart            ← ABSTRACT (implementasi TBD)
│   │   │   → method: Future<String> extractText(String imagePath)
│   │   ├── ocr_datasource_impl.dart       ← Implementasi aktif (swap-able)
│   │   ├── ai_parser_datasource.dart      ← ABSTRACT (LLM API, TBD)
│   │   │   → method: Future<Map> parseReceiptText(String rawText)
│   │   └── ai_parser_datasource_impl.dart
│   └── repositories/
│       └── receipt_repository_impl.dart
│
└── presentation/
    ├── controllers/
    │   └── receipt_scanner_controller.dart
    │       → State: isScanning, isProcessing, scanResult, quotaRemaining
    └── pages/
        └── receipt_scanner_page.dart
```

### State di Controller

```dart
// Reactive state
final RxBool _isScanning = false.obs;
final RxBool _isProcessing = false.obs;
final Rx<ScannedReceiptEntity?> _scanResult = Rx(null);
final RxInt _quotaRemaining = 0.obs;

// Dipanggil di onInit()
Future<void> _checkQuota() async {
  final result = await checkScanQuotaUseCase(NoParams());
  result.fold(
    (failure) => AppLogger.error('Quota check failed', failure),
    (quota) => _quotaRemaining.value = quota,
  );
}
```

---

## 2. Voice Quick Record

### Deskripsi
Pengguna menekan tombol mic, berbicara secara natural ("tadi beli kopi 25 ribu"), dan sistem secara otomatis:
1. Mentranskripsi suara ke teks menggunakan `speech_to_text` (on-device)
2. Mengirim teks ke LLM API untuk parsing intent → ekstrak nominal, kategori, arah (income/expense)
3. Pre-fill form tambah transaksi dengan data hasil parsing

### Flow Lengkap

```
1. User tap tombol mikrofon (FAB floating di home)
2. Cek permission mikrofon → request jika belum
3. Cek kuota voice (Free: 20x/bulan | PRO: unlimited)
4. Mulai listening via speech_to_text (on-device, tidak butuh internet)
5. User bicara: "beli makan siang 35 ribu dari dompet BCA"
6. speech_to_text menghentikan otomatis setelah silence, atau user tap stop
7. Kirim teks ke LLM API:
   → Prompt: "Parse transaksi keuangan dari teks berikut. Kembalikan JSON dengan field:
              amount (number), type (income/expense/transfer), category (string),
              wallet (string, opsional), note (string, opsional), currency (string, default: IDR)"
8. LLM mengembalikan JSON terstruktur
9. Pre-fill form AddTransaction dengan data JSON
10. User konfirmasi / koreksi → simpan
11. Dekremen kuota voice bulanan user
```

### Batasan Freemium

```
FREE:
- Kuota: 20 voice record per bulan
- Indikator kuota di halaman / tooltip tombol mic

PRO:
- Unlimited voice record
- (Future) Riwayat voice record, re-parse ulang
```

### Parsing Intent — Kontrak LLM

LLM API apapun yang digunakan **wajib mengembalikan format JSON berikut**. Kontrak ini tidak boleh berubah meskipun implementasi LLM berganti:

```json
{
  "amount": 35000,
  "type": "expense",
  "category": "Makan & Minum",
  "wallet": "BCA",
  "note": "Makan siang",
  "currency": "IDR",
  "confidence": 0.92
}
```

Jika field tidak terdeteksi, kembalikan `null`. Controller yang memutuskan apakah nilai `null` acceptable atau perlu input manual dari user.

### Struktur Fitur

```
features/voice_record/
├── domain/
│   ├── entities/
│   │   └── voice_intent_entity.dart
│   │       → amount, type, category, wallet, note, currency, confidence
│   ├── repositories/
│   │   └── voice_record_repository.dart
│   └── usecases/
│       ├── start_voice_recording_usecase.dart
│       ├── stop_voice_recording_usecase.dart
│       ├── parse_voice_intent_usecase.dart    ← Params: transcribedText
│       └── check_voice_quota_usecase.dart
│
├── data/
│   ├── datasources/
│   │   ├── voice_transcriber_datasource.dart       ← ABSTRACT (speech_to_text wrapper)
│   │   ├── voice_transcriber_datasource_impl.dart
│   │   ├── voice_intent_parser_datasource.dart     ← ABSTRACT (LLM API, TBD)
│   │   └── voice_intent_parser_datasource_impl.dart
│   └── repositories/
│       └── voice_record_repository_impl.dart
│
└── presentation/
    ├── controllers/
    │   └── voice_record_controller.dart
    └── widgets/
        └── voice_record_bottom_sheet.dart   ← Muncul sebagai bottom sheet
```

---

## 3. Premium Themes, Icons & Menu Ordering

### Deskripsi
Pengguna dapat mengkustomisasi tampilan aplikasi: tema warna, icon pack, tampilan kartu dompet, urutan menu di home. Sistem Freemium memblokir tema & ikon premium untuk akun Free.

### Daftar Item Kustomisasi

| Item | Free | PRO |
|------|------|-----|
| **Tema: Klasik** (abu-abu netral) | ✅ | ✅ |
| **Tema: Samudra** (biru-hijau, default UI screenshot) | ✅ | ✅ |
| **Tema: Seaside PRO** | ❌ (terkunci) | ✅ |
| **Tema: Neon Fever** | ❌ (terkunci) | ✅ |
| **Tema: Midnight** | ❌ (terkunci) | ✅ |
| **Icon Pack: Default** | ✅ | ✅ |
| **Icon Pack: Rounded PRO** | ❌ | ✅ |
| **Icon Pack: Sharp PRO** | ❌ | ✅ |
| **Tampilan Kartu** (style kartu dompet) | ✅ 1 style | ✅ Semua style |
| **Tampilan Menu** (grid/list) | ✅ | ✅ |
| **Urutan Menu Kustom** (drag & drop) | ❌ | ✅ |
| **Palet Warna Kustom** | ❌ | ✅ |
| **Bar Appearance** (bottom nav style) | ✅ | ✅ |
| **Format Saldo** (Rp1.000 / 1,000 IDR / dll) | ✅ | ✅ |

### Flow Gating Fitur PRO

```dart
// Di ThemeController (atau PremiumController)
Future<void> applyTheme(String themeId) async {
  final theme = availableThemes.firstWhere((t) => t.id == themeId);

  if (theme.isPremium && !currentUser.isPro) {
    // Tampilkan bottom sheet upgrade PRO
    Get.bottomSheet(UpgradePremiumSheet(featureName: 'Tema ${theme.name}'));
    return; // Hentikan — jangan apply tema
  }

  // Tema gratis atau user sudah PRO → apply
  await applyThemeUseCase(ApplyThemeParams(themeId: themeId));
  _activeTheme.value = theme;
  StorageService.write('active_theme_id', themeId);
}
```

### Struktur Tema di Assets

```
assets/
├── themes/
│   ├── free/
│   │   ├── classic.json       # Color tokens tema Klasik
│   │   └── ocean.json         # Color tokens tema Samudra
│   └── premium/
│       ├── seaside_pro.json
│       ├── neon_fever.json
│       └── midnight.json
└── icons/
    ├── free/
    │   └── default/           # SVG icon pack default
    └── premium/
        ├── rounded_pro/
        └── sharp_pro/
```

Setiap file `.json` tema mendefinisikan color tokens yang di-load ke `AppColors` secara dinamis saat runtime.

### Struktur Fitur

```
features/theme/
├── domain/
│   ├── entities/
│   │   ├── theme_entity.dart      → id, name, isPremium, previewImagePath, colorTokens
│   │   └── icon_pack_entity.dart  → id, name, isPremium, previewImagePath
│   ├── repositories/
│   │   └── theme_repository.dart
│   └── usecases/
│       ├── get_available_themes_usecase.dart
│       ├── apply_theme_usecase.dart
│       ├── get_available_icon_packs_usecase.dart
│       ├── apply_icon_pack_usecase.dart
│       └── save_menu_order_usecase.dart    ← PRO only
├── data/ ...
└── presentation/
    ├── controllers/
    │   └── theme_controller.dart   ← permanent: true di InitialBinding
    └── pages/
        ├── theme_picker_page.dart
        ├── icon_pack_page.dart
        └── menu_order_page.dart    ← Drag & drop, PRO only
```

**`ThemeController` harus didaftarkan sebagai `permanent: true`** di `InitialBinding` karena tema berlaku global di seluruh aplikasi.

---

## 4. Weekly / Period Statistics

### Deskripsi
Halaman analisis keuangan dengan grafik dan ringkasan. Berdasarkan screenshot, terdapat:
- Tab periode: Mingguan | Bulanan | Tahunan | Rentang (custom date range)
- Navigator periode (← April 2026 →)
- Toggle: Pemasukan / Pengeluaran
- Area chart atau bar chart
- Ringkasan Harian (tabel per hari dalam periode)
- Rata-rata In / Rata-rata Out / Rata-rata Net

### Flow

```
1. User buka tab Statistik
2. Default: tampilkan data Bulanan, bulan saat ini
3. User bisa:
   - Ganti tab (Mingguan / Bulanan / Tahunan / Rentang)
   - Navigasi periode ← →
   - Toggle Pemasukan / Pengeluaran
4. Saat parameter berubah → fetch data dari Supabase (dengan cache sqflite)
5. Render chart menggunakan fl_chart
6. Render tabel Ringkasan Harian di bawah chart
```

### Data yang Dibutuhkan

```dart
class StatisticsSummaryEntity {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final double avgDailyIncome;
  final double avgDailyExpense;
  final List<DailyDataPointEntity> dailyBreakdown; // Untuk chart
  final List<CategoryBreakdownEntity> categoryBreakdown; // Pie chart opsional
}

class DailyDataPointEntity {
  final DateTime date;
  final double income;
  final double expense;
}
```

### Struktur Fitur

```
features/statistics/
├── domain/
│   ├── entities/
│   │   ├── statistics_summary_entity.dart
│   │   ├── daily_data_point_entity.dart
│   │   └── category_breakdown_entity.dart
│   ├── repositories/
│   │   └── statistics_repository.dart
│   └── usecases/
│       ├── get_period_statistics_usecase.dart   ← Params: startDate, endDate, type
│       └── get_category_breakdown_usecase.dart
├── data/ ...
└── presentation/
    ├── controllers/
    │   └── statistics_controller.dart
    │       → State: selectedPeriod, selectedDate, isShowingIncome, summaryData
    └── pages/
        └── statistics_page.dart
```

---

## 5. Full Local Backup & Offline Support

### Deskripsi
Strategi **Cloud-First dengan Offline Queue**:
- **Online:** Data langsung disimpan ke Supabase. `sqflite` menyimpan cache lokal untuk read cepat.
- **Offline:** Transaksi baru masuk ke `offline_queue` di `sqflite`. Saat koneksi kembali, queue otomatis di-sync ke Supabase.

### Alur Sync Detail

```
SKENARIO ONLINE:
User tambah transaksi
  → TransactionRepositoryImpl.addTransaction()
  → Cek koneksi: ONLINE
  → RemoteDataSource.insertTransaction() [Supabase]
  → Jika sukses: LocalDataSource.cacheTransaction() [sqflite — untuk offline read]
  → Return Right(TransactionEntity)

SKENARIO OFFLINE:
User tambah transaksi
  → TransactionRepositoryImpl.addTransaction()
  → Cek koneksi: OFFLINE
  → LocalDataSource.addToOfflineQueue() [sqflite — dengan status 'PENDING']
  → Return Right(TransactionEntity) [UI tidak perlu tahu ini offline]

SKENARIO RECONNECT:
App mendeteksi koneksi kembali (via connectivity_plus listener)
  → SyncOfflineQueueUseCase dipanggil oleh SyncController
  → Ambil semua record dari offline_queue WHERE status = 'PENDING'
  → Untuk setiap record: RemoteDataSource.insertTransaction()
  → Jika sukses: update status queue → 'SYNCED' (atau hapus dari queue)
  → Jika gagal: status tetap 'PENDING' (akan retry berikutnya)
```

### Tabel `sqflite` untuk Offline Queue

```sql
-- Di LocalDatabaseService.init()
CREATE TABLE IF NOT EXISTS offline_queue (
  id          TEXT PRIMARY KEY,        -- UUID lokal
  action      TEXT NOT NULL,           -- 'INSERT', 'UPDATE', 'DELETE'
  entity_type TEXT NOT NULL,           -- 'transaction', 'wallet', dll
  payload     TEXT NOT NULL,           -- JSON string dari data
  status      TEXT DEFAULT 'PENDING',  -- 'PENDING', 'SYNCED', 'FAILED'
  created_at  INTEGER NOT NULL,        -- Unix timestamp
  retry_count INTEGER DEFAULT 0
);

-- Cache transaksi untuk offline read
CREATE TABLE IF NOT EXISTS transactions_cache (
  id              TEXT PRIMARY KEY,
  user_id         TEXT NOT NULL,
  amount          REAL NOT NULL,
  type            TEXT NOT NULL,
  category_id     TEXT,
  wallet_id       TEXT,
  note            TEXT,
  date            INTEGER NOT NULL,
  is_synced       INTEGER DEFAULT 1,   -- 0 = masih di queue
  created_at      INTEGER NOT NULL
);

-- Cache kurs mata uang
CREATE TABLE IF NOT EXISTS exchange_rates_cache (
  base_currency   TEXT NOT NULL,
  target_currency TEXT NOT NULL,
  rate            REAL NOT NULL,
  fetched_at      INTEGER NOT NULL,    -- Unix timestamp
  PRIMARY KEY (base_currency, target_currency)
);
```

### Struktur Controller Sync

```dart
// Di SyncController (permanent: true di InitialBinding)
class SyncController extends GetxController {
  final SyncOfflineQueueUseCase syncOfflineQueueUseCase;

  final RxBool _isSyncing = false.obs;
  final RxInt _pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen perubahan koneksi
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      syncNow();  // Otomatis sync saat koneksi kembali
    }
  }

  Future<void> syncNow() async {
    if (_isSyncing.value) return;
    _isSyncing.value = true;
    final result = await syncOfflineQueueUseCase(NoParams());
    result.fold(
      (failure) => AppLogger.error('Sync failed', failure),
      (syncedCount) => AppLogger.info('Synced $syncedCount items'),
    );
    _isSyncing.value = false;
  }
}
```

---

## 6. Smart Notes

### Deskripsi
Setiap transaksi dapat dilampiri catatan teks bebas. "Smart" di sini berarti:
- Pencarian catatan full-text
- Tag/label opsional per catatan
- Catatan bisa berisi emoji
- (Future) AI-summarize catatan bulanan

### Entitas

```dart
class SmartNoteEntity {
  final String id;
  final String transactionId;  // Relasi ke transaksi
  final String content;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Integrasi dengan Transaksi
Smart Notes bukan fitur berdiri sendiri — ia adalah field opsional dalam form tambah transaksi. Disimpan di kolom `note` (Supabase) dan diindeks untuk pencarian.

---

## 7. Recurring Transactions

### Deskripsi
Pengguna mendefinisikan transaksi berulang (misal: "Bayar Netflix Rp 54.000 setiap tanggal 15"). Sistem otomatis membuat entry transaksi pada jadwal yang ditentukan.

### Jenis Recurrence

```dart
enum RecurrenceType {
  daily,    // Setiap hari
  weekly,   // Setiap minggu (+ pilih hari)
  monthly,  // Setiap bulan (+ pilih tanggal)
  yearly,   // Setiap tahun
  custom,   // Custom interval (setiap N hari)
}
```

### Flow Pemrosesan Otomatis

```
Saat app dibuka (AppLifecycleState.resumed):
→ RecurringController.checkDueTodayUseCase()
→ Ambil semua recurring transactions WHERE next_due_date <= TODAY
→ Untuk setiap yang jatuh tempo:
   → Buat transaksi baru (insert ke transactions)
   → Update next_due_date ke jadwal berikutnya
→ Tampilkan badge notifikasi jika ada yang otomatis masuk
```

### Entitas

```dart
class RecurringTransactionEntity {
  final String id;
  final String userId;
  final double amount;
  final String type;           // income / expense
  final String categoryId;
  final String walletId;
  final String? note;
  final RecurrenceType recurrenceType;
  final int? recurrenceValue;  // Untuk custom: setiap N hari
  final int? dayOfWeek;        // Untuk weekly: 1-7
  final int? dayOfMonth;       // Untuk monthly: 1-31
  final DateTime startDate;
  final DateTime? endDate;     // null = tidak ada batas
  final DateTime nextDueDate;
  final bool isActive;
}
```

---

## 8. Professional Currency Picker & Exchange Rates

### Deskripsi
Pengguna bisa mencatat transaksi dalam mata uang berbeda. Nilai dikonversi ke mata uang default (IDR) secara otomatis menggunakan kurs harian. Data kurs di-cache di `sqflite` untuk menghindari API call berlebihan.

### Strategi Cache Exchange Rates

```
1. User tambah transaksi dengan mata uang non-IDR (misal: USD 10)
2. ExchangeRateRepository.getRate(base: 'USD', target: 'IDR')
3. Cek cache sqflite: apakah ada rate USD→IDR yang fetched_at < 24 jam?
   └── YA → gunakan rate dari cache (tidak panggil API)
   └── TIDAK → panggil Exchange Rate API → simpan ke cache → return rate
4. Konversi: 10 USD × rate = amount dalam IDR
5. Simpan KEDUA nilai: original_amount (10 USD) & converted_amount (dalam IDR)
```

### Entitas

```dart
class ExchangeRateEntity {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime fetchedAt;
}

class CurrencyEntity {
  final String code;     // 'USD', 'IDR', 'EUR'
  final String name;     // 'US Dollar'
  final String symbol;   // '$', 'Rp', '€'
  final String flag;     // '🇺🇸', '🇮🇩', '🇪🇺'
}
```

### Abstract Contract Exchange Rate (Implementasi TBD)

Lihat detail di [`TECHNICAL_GUIDELINES.md`](TECHNICAL_GUIDELINES.md#3-abstract-contract-exchange-rate-datasource).

---

## 9. Export Data

### Deskripsi
Pengguna dapat mengekspor riwayat transaksi ke file yang bisa dibagikan atau dibuka di spreadsheet.

### Format & Batasan Freemium

| Format | Free | PRO |
|--------|------|-----|
| CSV | ✅ | ✅ |
| Excel (.xlsx) | ❌ | ✅ |
| PDF (report visual) | ❌ | ✅ |

### Flow Export

```
1. User pilih format export & rentang tanggal
2. Cek akses format berdasarkan status PRO
3. Fetch data transaksi dalam rentang dari Supabase (atau cache lokal)
4. Proses on-device:
   - CSV: package `csv` → generate string → simpan ke file
   - Excel: package `excel` → generate .xlsx → simpan ke file
   - PDF: package `pdf` + `printing` → generate PDF dengan branding fluxa
5. Buka share sheet OS (Share.shareXFiles) → user bisa kirim ke email, Drive, dll
```

### Konten File Export

```
Kolom (CSV/Excel):
Tanggal | Tipe | Kategori | Dompet | Nominal | Mata Uang | Nominal (IDR) | Catatan | Berulang?

PDF Report mencakup:
- Header: "Laporan Keuangan fluxa — [Periode]"
- Ringkasan: Total Pemasukan, Total Pengeluaran, Saldo Bersih
- Grafik pie kategori pengeluaran
- Tabel transaksi lengkap
```

### Struktur Fitur

```
features/export/
├── domain/
│   ├── entities/
│   │   └── export_config_entity.dart  → format, startDate, endDate
│   ├── repositories/
│   │   └── export_repository.dart
│   └── usecases/
│       ├── export_csv_usecase.dart
│       ├── export_excel_usecase.dart  ← PRO only (cek di controller)
│       └── export_pdf_usecase.dart    ← PRO only
├── data/
│   ├── datasources/
│   │   └── export_datasource_impl.dart  ← Proses file on-device (tidak perlu Abstract)
│   └── repositories/
│       └── export_repository_impl.dart
└── presentation/
    ├── controllers/
    │   └── export_controller.dart
    └── pages/
        └── export_page.dart
```

---

*Kembali ke: [README.md](../README.md) | [DATABASE.md](DATABASE.md) | [TECHNICAL_GUIDELINES.md](TECHNICAL_GUIDELINES.md)*
