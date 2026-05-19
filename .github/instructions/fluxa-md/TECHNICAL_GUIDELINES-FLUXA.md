# TECHNICAL_GUIDELINES.md — Panduan Teknis & Arsitektur fluxa_app

> Kembali ke: [README.md](../README.md) | [FEATURES.md](FEATURES.md) | [DATABASE.md](DATABASE.md)

---

## Daftar Isi

1. [Aturan Arsitektur (Wajib Diikuti)](#1-aturan-arsitektur-wajib-diikuti)
2. [Konvensi Koding](#2-konvensi-koding)
3. [Abstract Contract — OCR DataSource](#3-abstract-contract--ocr-datasource)
4. [Abstract Contract — Voice Intent Parser DataSource](#4-abstract-contract--voice-intent-parser-datasource)
5. [Abstract Contract — Exchange Rate DataSource](#5-abstract-contract--exchange-rate-datasource)
6. [Cara Menukar Implementasi (Swap Implementation)](#6-cara-menukar-implementasi-swap-implementation)
7. [Dependency Injection Rules (GetX)](#7-dependency-injection-rules-getx)
8. [Error Handling Rules](#8-error-handling-rules)
9. [State Management Rules (GetX Rx)](#9-state-management-rules-getx-rx)
10. [Freemium Guard Pattern](#10-freemium-guard-pattern)
11. [Checklist Membuat Fitur Baru](#11-checklist-membuat-fitur-baru)

---

## 1. Aturan Arsitektur (Wajib Diikuti)

Semua aturan ini merujuk langsung ke `struktur.md`, `struktur_core.md`, dan `struktur_feature.md`. Tidak boleh membuat standar arsitektur baru.

### 1.1 Aturan Arah Dependency

```
Presentation → Domain ← Data

✅ Presentation boleh import Domain (Entity, UseCase)
✅ Data boleh import Domain (untuk implement Repository contract & convert Model → Entity)
❌ Domain TIDAK BOLEH import Presentation atau Data
❌ Domain TIDAK BOLEH import package eksternal selain `dartz`
❌ Fitur A TIDAK BOLEH import langsung dari fitur B (kecuali via UseCase yang di-inject)
```

### 1.2 Aturan Layer

| Layer | Boleh Import | Tidak Boleh Import |
|-------|-------------|---------------------|
| `domain/entities/` | Tidak ada (murni Dart) | Segalanya |
| `domain/repositories/` | `dartz`, `core/errors/failures.dart`, entities | Data layer, Presentation, Flutter |
| `domain/usecases/` | `dartz`, `core/usecases/usecase.dart`, domain repository, entities | Data layer, GetX, Flutter |
| `data/models/` | Entities | Domain repositories, Presentation |
| `data/datasources/` | Models, Supabase, sqflite, packages eksternal | Domain, Presentation |
| `data/repositories/` | Domain repository contract, datasources, models, `dartz`, `core/errors/` | Presentation |
| `presentation/bindings/` | GetX, datasources, repositories, usecases, controllers | UI widgets langsung |
| `presentation/controllers/` | GetX, domain usecases, entities, `core/` utils | Data layer langsung |
| `presentation/pages/` | GetX, controllers, widgets, `core/constants/` | UseCases, Repositories langsung |

### 1.3 Aturan Domain Layer

```dart
// ✅ BENAR: Domain entity hanya berisi properti
class TransactionEntity {
  final String id;
  final double amount;
  final String type;
  // ...
  TransactionEntity({required this.id, required this.amount, required this.type});
}

// ❌ SALAH: Entity TIDAK boleh punya fromJson/toJson
class TransactionEntity {
  // ...
  factory TransactionEntity.fromJson(Map<String, dynamic> json) { ... } // ← DILARANG
  Map<String, dynamic> toJson() { ... }  // ← DILARANG
}
```

### 1.4 Aturan Model

```dart
// ✅ BENAR: Model extends Entity + fromJson/toJson/toEntity
class TransactionModel extends TransactionEntity {
  TransactionModel({required super.id, required super.amount, required super.type});

  factory TransactionModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
  TransactionEntity toEntity() => this; // Karena sudah extends Entity
}

// ❌ SALAH: Model mengimplementasikan Entity alih-alih extends
class TransactionModel implements TransactionEntity { ... } // ← Hindari
```

### 1.5 Aturan Repository Implementation

```dart
// ✅ BENAR: try-catch di setiap method, konversi Model → Entity di sini
@override
Future<Either<Failure, TransactionEntity>> getTransaction(String id) async {
  try {
    final model = await remoteDataSource.getTransaction(id);
    return Right(model.toEntity());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}

// ❌ SALAH: Tidak ada try-catch, atau melempar exception ke atas
@override
Future<Either<Failure, TransactionEntity>> getTransaction(String id) async {
  final model = await remoteDataSource.getTransaction(id); // Exception tidak ditangkap!
  return Right(model.toEntity());
}
```

---

## 2. Konvensi Koding

### 2.1 Penamaan File

| Jenis | Format | Contoh |
|-------|--------|--------|
| Entity | `{nama}_entity.dart` | `transaction_entity.dart` |
| Model | `{nama}_model.dart` | `transaction_model.dart` |
| DataSource (abstract) | `{nama}_datasource.dart` | `ocr_datasource.dart` |
| DataSource (impl) | `{nama}_datasource_impl.dart` | `ocr_datasource_impl.dart` |
| Repository (contract) | `{nama}_repository.dart` | `transaction_repository.dart` |
| Repository (impl) | `{nama}_repository_impl.dart` | `transaction_repository_impl.dart` |
| UseCase | `{aksi}_{nama}_usecase.dart` | `add_transaction_usecase.dart` |
| Binding | `{nama}_binding.dart` | `transaction_binding.dart` |
| Controller | `{nama}_controller.dart` | `transaction_controller.dart` |
| Page | `{nama}_page.dart` | `add_transaction_page.dart` |
| Widget | `{nama}_{deskripsi}_widget.dart` | `balance_card_widget.dart` |

Semua file: **snake_case**. Semua class: **PascalCase**. Semua variabel/method: **camelCase**.

### 2.2 Struktur Controller (Standar)

```dart
class ExampleController extends GetxController {
  // 1. Inject dependensi via constructor (bukan Get.find di dalam controller)
  final SomeUseCase someUseCase;
  ExampleController({required this.someUseCase});

  // 2. State → private Rx, public getter (BUKAN public Rx)
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxList<SomeEntity> _items = <SomeEntity>[].obs;
  List<SomeEntity> get items => _items;

  final Rx<SomeEntity?> _selectedItem = Rx(null);
  SomeEntity? get selectedItem => _selectedItem.value;

  // 3. Lifecycle
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  // 4. Private loader (dipanggil dari onInit)
  Future<void> _loadInitialData() async {
    _isLoading.value = true;
    await Future.wait([loadItems()]);
    _isLoading.value = false;
  }

  // 5. Public methods (dipanggil dari Page)
  Future<void> loadItems() async {
    final result = await someUseCase(NoParams());
    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (items) => _items.value = items,
    );
  }
}
```

### 2.3 Struktur Page (Standar)

```dart
// Gunakan GetView<Controller>, BUKAN StatelessWidget + Get.find
class ExamplePage extends GetView<ExampleController> {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Example')),
      body: Obx(() {
        if (controller.isLoading) {
          return const AppLoadingWidget();
        }
        if (controller.items.isEmpty) {
          return const AppEmptyStateWidget(message: 'Belum ada data');
        }
        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (_, i) => ExampleItemWidget(item: controller.items[i]),
        );
      }),
    );
  }
}
```

---

## 3. Abstract Contract — OCR DataSource

> **Latar Belakang:** Implementasi OCR masih TBD (kandidat: `google_mlkit_text_recognition`, Tesseract, atau API cloud seperti Google Vision / AWS Textract). Agar mudah ditukar tanpa mengubah kode di layer atas, **wajib dibungkus Abstract Contract.**

### 3.1 Abstract Class (Domain-Facing Contract)

```dart
// lib/features/receipt_scanner/data/datasources/ocr_datasource.dart

/// Abstract contract untuk layanan OCR.
/// Implementasi konkret DAPAT DIGANTI tanpa mengubah Repository atau UseCase.
///
/// Saat ini: [OcrDatasourceImpl] menggunakan google_mlkit_text_recognition.
/// Jika diganti ke API eksternal, cukup buat [OcrApiDatasourceImpl] baru
/// dan daftarkan di [ReceiptScannerBinding] menggantikan yang lama.
abstract class OcrDatasource {
  /// Mengekstrak teks dari gambar di [imagePath].
  ///
  /// [imagePath] → Path absolut file gambar di storage lokal device.
  ///
  /// Return: Raw teks hasil ekstraksi (belum diparsing).
  /// Throws [ServerException] jika OCR gagal (gambar buram, format tidak didukung, dll).
  Future<String> extractText(String imagePath);

  /// Mengecek apakah layanan OCR tersedia di device saat ini.
  /// (Misal: model ML belum diunduh, izin kamera belum diberikan).
  Future<bool> isAvailable();

  /// Melepas resource (model ML) jika perlu.
  Future<void> dispose();
}
```

### 3.2 Implementasi Aktif (Swap-able)

```dart
// lib/features/receipt_scanner/data/datasources/ocr_datasource_impl.dart

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../../core/errors/exceptions.dart';
import 'ocr_datasource.dart';

/// Implementasi OcrDatasource menggunakan google_mlkit_text_recognition.
/// Berjalan sepenuhnya on-device (tidak perlu internet).
///
/// UNTUK MENGGANTI IMPLEMENTASI:
/// 1. Buat file baru, misal: ocr_api_datasource_impl.dart
/// 2. Implementasikan abstract class OcrDatasource
/// 3. Di ReceiptScannerBinding, ganti:
///    Get.lazyPut<OcrDatasource>(() => OcrDatasourceImpl())
///    menjadi:
///    Get.lazyPut<OcrDatasource>(() => OcrApiDatasourceImpl(apiKey: '...'))
class OcrDatasourceImpl implements OcrDatasource {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw ServerException('OCR gagal memproses gambar: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAvailable() async {
    // ML Kit selalu tersedia jika package terinstal
    return true;
  }

  @override
  Future<void> dispose() async {
    await _recognizer.close();
  }
}
```

### 3.3 Abstract Class untuk AI Parser

```dart
// lib/features/receipt_scanner/data/datasources/ai_parser_datasource.dart

import '../models/parsed_receipt_model.dart';

/// Abstract contract untuk layanan parsing AI (LLM).
/// Input: raw text dari OCR.
/// Output: data transaksi terstruktur.
///
/// Implementasi TBD: OpenAI API / Gemini API / Mistral / On-device model.
abstract class AiParserDatasource {
  /// Mem-parse raw teks OCR menjadi data transaksi terstruktur.
  ///
  /// [rawOcrText] → Teks mentah hasil OCR dari struk.
  ///
  /// Return: [ParsedReceiptModel] dengan field yang berhasil diekstrak.
  ///         Field yang tidak berhasil diekstrak bernilai null.
  /// Throws [ServerException] jika API call gagal.
  Future<ParsedReceiptModel> parseReceiptText(String rawOcrText);
}
```

### 3.4 Model Hasil Parsing (Kontrak Output — Tidak Boleh Berubah)

```dart
// lib/features/receipt_scanner/data/models/parsed_receipt_model.dart

import '../../domain/entities/scanned_receipt_entity.dart';

/// Model ini adalah KONTRAK OUTPUT yang tidak boleh berubah,
/// meskipun implementasi AI parser berganti.
/// Semua implementasi AiParserDatasource WAJIB mengembalikan format ini.
class ParsedReceiptModel extends ScannedReceiptEntity {
  ParsedReceiptModel({
    required super.id,
    super.parsedAmount,
    super.parsedCategory,
    super.parsedMerchant,
    super.parsedDate,
    super.parsedCurrency,
    super.confidence,
    super.rawOcrText,
  });

  factory ParsedReceiptModel.fromLlmJson(Map<String, dynamic> json) {
    return ParsedReceiptModel(
      id: const Uuid().v4(),
      parsedAmount: (json['amount'] as num?)?.toDouble(),
      parsedCategory: json['category'] as String?,
      parsedMerchant: json['merchant'] as String?,
      parsedDate: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      parsedCurrency: json['currency'] as String? ?? 'IDR',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ScannedReceiptEntity toEntity() => this;
}
```

---

## 4. Abstract Contract — Voice Intent Parser DataSource

> **Latar Belakang:** `speech_to_text` untuk transkripsi suara sudah pasti, tapi LLM API untuk parsing intent masih TBD (OpenAI, Gemini, atau model lokal).

### 4.1 Abstract Contract (Transkripsi)

```dart
// lib/features/voice_record/data/datasources/voice_transcriber_datasource.dart

/// Abstract contract untuk layanan transkripsi suara → teks.
/// Implementasi default: speech_to_text (on-device).
/// Bisa diganti ke API cloud jika dibutuhkan akurasi lebih tinggi.
abstract class VoiceTranscriberDatasource {
  /// Mulai sesi perekaman suara.
  /// Throws [PermissionException] jika izin mikrofon belum diberikan.
  Future<void> startListening({
    required void Function(String partialResult) onPartialResult,
    required void Function(String finalResult) onFinalResult,
    required void Function(String error) onError,
    String localeId = 'id_ID',  // Default Bahasa Indonesia
  });

  /// Hentikan perekaman dan kembalikan teks final.
  Future<String> stopListening();

  /// Batalkan perekaman tanpa hasil.
  Future<void> cancelListening();

  /// Apakah mikrofon sedang aktif merekam?
  bool get isListening;

  /// Apakah speech_to_text tersedia di device ini?
  Future<bool> isAvailable();
}
```

### 4.2 Abstract Contract (Parsing Intent LLM)

```dart
// lib/features/voice_record/data/datasources/voice_intent_parser_datasource.dart

import '../models/voice_intent_model.dart';

/// Abstract contract untuk parsing intent dari teks natural language.
/// Implementasi TBD: OpenAI API / Gemini API / Mistral / model lokal.
///
/// INPUT : "beli makan siang 35 ribu dari BCA"
/// OUTPUT: VoiceIntentModel { amount: 35000, type: 'expense', category: 'Makan & Minum', ... }
abstract class VoiceIntentParserDatasource {
  /// Mem-parse teks natural language menjadi data transaksi.
  ///
  /// [transcribedText] → Hasil transkripsi suara.
  /// [availableCategories] → Daftar kategori yang dimiliki user (untuk membantu AI
  ///                         memilih kategori yang paling relevan).
  /// [availableWallets] → Daftar nama dompet user.
  ///
  /// Return: [VoiceIntentModel] — field null jika tidak terdeteksi.
  /// Throws [ServerException] jika API call gagal.
  Future<VoiceIntentModel> parseIntent({
    required String transcribedText,
    List<String> availableCategories = const [],
    List<String> availableWallets = const [],
  });
}
```

### 4.3 Model Output Voice Intent (Kontrak Tidak Boleh Berubah)

```dart
// lib/features/voice_record/data/models/voice_intent_model.dart

import '../../domain/entities/voice_intent_entity.dart';

class VoiceIntentModel extends VoiceIntentEntity {
  VoiceIntentModel({
    super.amount,
    super.type,
    super.category,
    super.wallet,
    super.note,
    super.currency,
    super.confidence,
  });

  /// Parse dari JSON yang dikembalikan LLM API.
  /// SEMUA implementasi AiParserDatasource WAJIB mengembalikan JSON format ini:
  /// {
  ///   "amount": 35000,          // number atau null
  ///   "type": "expense",        // "income" | "expense" | "transfer" | null
  ///   "category": "Makan",      // string atau null
  ///   "wallet": "BCA",          // string atau null
  ///   "note": "makan siang",    // string atau null
  ///   "currency": "IDR",        // string, default IDR
  ///   "confidence": 0.92        // 0.0 - 1.0
  /// }
  factory VoiceIntentModel.fromLlmJson(Map<String, dynamic> json) {
    return VoiceIntentModel(
      amount: (json['amount'] as num?)?.toDouble(),
      type: json['type'] as String?,
      category: json['category'] as String?,
      wallet: json['wallet'] as String?,
      note: json['note'] as String?,
      currency: json['currency'] as String? ?? 'IDR',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  VoiceIntentEntity toEntity() => this;
}
```

### 4.4 Prompt Standar untuk LLM (Disimpan di Konstanta)

```dart
// lib/core/constants/ai_prompts.dart

class AiPrompts {
  AiPrompts._();

  static String voiceIntentPrompt({
    required String transcribedText,
    required List<String> categories,
    required List<String> wallets,
  }) => '''
Kamu adalah asisten pencatatan keuangan. Parse teks berikut menjadi data transaksi JSON.

Teks: "$transcribedText"
Kategori tersedia: ${categories.join(', ')}
Dompet tersedia: ${wallets.join(', ')}

Kembalikan HANYA JSON valid (tanpa markdown, tanpa penjelasan):
{
  "amount": <number atau null>,
  "type": <"income" | "expense" | "transfer" | null>,
  "category": <string yang paling cocok dari daftar kategori, atau null>,
  "wallet": <string yang paling cocok dari daftar dompet, atau null>,
  "note": <string singkat deskripsi, atau null>,
  "currency": <kode mata uang 3 huruf, default "IDR">,
  "confidence": <number 0.0 - 1.0>
}
''';

  static String receiptParsePrompt(String rawOcrText) => '''
Kamu adalah asisten ekstraksi data struk belanja. Parse teks OCR berikut.

Teks OCR:
"""
$rawOcrText
"""

Kembalikan HANYA JSON valid:
{
  "amount": <total pembayaran sebagai number, atau null>,
  "category": <kategori belanja yang paling cocok, atau null>,
  "merchant": <nama toko/merchant, atau null>,
  "date": <tanggal dalam format YYYY-MM-DD, atau null>,
  "currency": <kode mata uang 3 huruf, default "IDR">,
  "confidence": <number 0.0 - 1.0>
}
''';
}
```

---

## 5. Abstract Contract — Exchange Rate DataSource

> **Latar Belakang:** API kurs masih TBD (kandidat: frankfurter.app [gratis], exchangeratesapi.io, fixer.io). Wajib diabstraksi agar mudah diganti tanpa refaktor besar.

### 5.1 Abstract Contract

```dart
// lib/features/currency/data/datasources/exchange_rate_datasource.dart

import '../models/exchange_rate_model.dart';

/// Abstract contract untuk layanan kurs mata uang.
/// Implementasi TBD: frankfurter.app / exchangeratesapi.io / fixer.io.
///
/// Data kurs di-cache di sqflite (TTL 24 jam) untuk mengurangi API calls.
/// Lihat ExchangeRateLocalDatasource untuk detail cache.
abstract class ExchangeRateDatasource {
  /// Mengambil kurs konversi dari [baseCurrency] ke [targetCurrency].
  ///
  /// [baseCurrency] → Mata uang asal (misal: 'USD')
  /// [targetCurrency] → Mata uang tujuan (misal: 'IDR')
  ///
  /// Return: [ExchangeRateModel] dengan rate terkini.
  /// Throws [ServerException] jika API tidak bisa dihubungi.
  /// Throws [NetworkException] jika tidak ada koneksi internet.
  Future<ExchangeRateModel> getRate({
    required String baseCurrency,
    required String targetCurrency,
  });

  /// Mengambil kurs untuk BANYAK target sekaligus (lebih efisien dari panggil satu per satu).
  ///
  /// [baseCurrency] → Mata uang dasar
  /// [targetCurrencies] → Daftar mata uang tujuan
  ///
  /// Return: Map dari currency code ke rate (misal: {'IDR': 15500.0, 'EUR': 0.92})
  Future<Map<String, double>> getRates({
    required String baseCurrency,
    required List<String> targetCurrencies,
  });

  /// Mengambil daftar mata uang yang didukung oleh provider ini.
  Future<List<String>> getSupportedCurrencies();
}
```

### 5.2 Repository dengan Strategi Cache-First

```dart
// lib/features/currency/data/repositories/currency_repository_impl.dart

class CurrencyRepositoryImpl implements CurrencyRepository {
  final ExchangeRateDatasource remoteDatasource;    // API eksternal
  final ExchangeRateLocalDatasource localDatasource; // sqflite cache

  CurrencyRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, double>> getExchangeRate({
    required String from,
    required String to,
  }) async {
    try {
      // 1. Cek cache (TTL 24 jam)
      final cached = await localDatasource.getCachedRate(base: from, target: to);
      if (cached != null) {
        AppLogger.debug('Exchange rate cache hit: $from → $to = $cached');
        return Right(cached);
      }

      // 2. Cache miss → fetch dari API
      AppLogger.info('Exchange rate cache miss, fetching from API: $from → $to');
      final model = await remoteDatasource.getRate(
        baseCurrency: from,
        targetCurrency: to,
      );

      // 3. Simpan ke cache
      await localDatasource.saveRate(
        base: from,
        target: to,
        rate: model.rate,
      );

      return Right(model.rate);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

---

## 6. Cara Menukar Implementasi (Swap Implementation)

Karena semua DataSource TBD dibungkus Abstract Contract, cara mengganti implementasi **hanya perlu mengubah 1 baris di Binding**. Tidak ada perubahan di Domain layer sama sekali.

### Contoh: Mengganti OCR dari ML Kit ke API Cloud

**Sebelum (ML Kit on-device):**
```dart
// receipt_scanner_binding.dart
Get.lazyPut<OcrDatasource>(() => OcrDatasourceImpl());   // ML Kit
```

**Sesudah (Google Vision API):**
```dart
// receipt_scanner_binding.dart
Get.lazyPut<OcrDatasource>(() => OcrApiDatasourceImpl(   // ← Ganti ini
  apiKey: AppConstants.googleVisionApiKey,
));
```

`OcrApiDatasourceImpl` cukup mengimplementasikan abstract class `OcrDatasource` yang sama. Semua layer di atasnya (Repository, UseCase, Controller, Page) tidak perlu diubah sama sekali.

### Contoh: Mengganti LLM dari OpenAI ke Gemini

```dart
// receipt_scanner_binding.dart
// Sebelum:
Get.lazyPut<AiParserDatasource>(() => OpenAiParserDatasourceImpl(apiKey: '...'));

// Sesudah:
Get.lazyPut<AiParserDatasource>(() => GeminiParserDatasourceImpl(apiKey: '...'));
```

---

## 7. Dependency Injection Rules (GetX)

### 7.1 Kapan Pakai `Get.put` vs `Get.lazyPut`

| Method | Kapan Digunakan |
|--------|-----------------|
| `Get.put(..., permanent: true)` | Dependency global yang hidup sepanjang siklus app (Auth, Theme, Sync controller) |
| `Get.put(...)` | Dependency yang perlu langsung tersedia saat Binding dibuat (jarang digunakan) |
| `Get.lazyPut(...)` | Dependency per-fitur — di-instansiasi hanya saat pertama kali dipanggil |

### 7.2 `InitialBinding` — Hanya untuk Global Dependency

```dart
// lib/core/di/initial_binding.dart
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Global: Auth state
    Get.put<AuthRemoteDataSource>(AuthRemoteDataSourceImpl(), permanent: true);
    Get.put<AuthRepository>(
      AuthRepositoryImpl(remoteDataSource: Get.find()),
      permanent: true,
    );
    Get.put(GetCurrentUserUseCase(repository: Get.find()), permanent: true);
    Get.put(AuthController(getCurrentUserUseCase: Get.find()), permanent: true);

    // ✅ Global: Theme (berlaku di seluruh app)
    Get.put(ThemeController(...), permanent: true);

    // ✅ Global: Sync (listen perubahan koneksi)
    Get.put(SyncController(...), permanent: true);

    // ✅ Global: Premium status (digunakan di mana-mana untuk gating)
    Get.put(PremiumController(...), permanent: true);

    // ❌ JANGAN masukkan controller per-fitur di sini
    // TransactionController, StatisticsController, dll → masuk di Binding masing-masing
  }
}
```

### 7.3 Urutan Registrasi di Setiap Binding

```dart
class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    // WAJIB URUT: DataSource → Repository → UseCase → Controller

    // 1. DataSources
    Get.lazyPut<TransactionRemoteDataSource>(() => TransactionRemoteDataSourceImpl());
    Get.lazyPut<TransactionLocalDataSource>(() => TransactionLocalDataSourceImpl());

    // 2. Repositories
    Get.lazyPut<TransactionRepository>(() => TransactionRepositoryImpl(
      remoteDataSource: Get.find(),
      localDataSource: Get.find(),
      connectivityService: ConnectivityService(),
    ));

    // 3. UseCases
    Get.lazyPut(() => AddTransactionUseCase(repository: Get.find()));
    Get.lazyPut(() => GetTransactionsUseCase(repository: Get.find()));
    Get.lazyPut(() => DeleteTransactionUseCase(repository: Get.find()));

    // 4. Controller
    Get.lazyPut(() => TransactionController(
      addTransactionUseCase: Get.find(),
      getTransactionsUseCase: Get.find(),
      deleteTransactionUseCase: Get.find(),
    ));
  }
}
```

---

## 8. Error Handling Rules

### 8.1 Exception vs Failure

```
Data Layer  → throw Exception (ServerException, NetworkException, AuthException, CacheException)
Repository  → catch Exception → return Left(Failure)
Controller  → result.fold((failure) → handle UI feedback, (data) → update state)
```

### 8.2 Custom Failures untuk fluxa_app

Tambahkan di `core/errors/failures.dart`:

```dart
// Tambahan spesifik fluxa_app
class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure(super.message);
}

class OfflineFailure extends Failure {
  const OfflineFailure(super.message);
}

class ParseFailure extends Failure {
  final double? confidence;
  const ParseFailure(super.message, {this.confidence});
}

class PremiumRequiredFailure extends Failure {
  final String featureName;
  const PremiumRequiredFailure(super.message, {required this.featureName});
}
```

### 8.3 Pola `result.fold()` di Controller

```dart
// ✅ SELALU handle kedua sisi
result.fold(
  (failure) {
    // Spesifik per tipe Failure
    if (failure is QuotaExceededFailure) {
      Get.bottomSheet(UpgradePremiumSheet());
    } else if (failure is NetworkFailure) {
      Get.snackbar('Offline', 'Data akan disinkronkan saat koneksi kembali');
    } else {
      Get.snackbar('Error', failure.message);
    }
  },
  (data) {
    _items.value = data;
  },
);
```

---

## 9. State Management Rules (GetX Rx)

```dart
// ✅ BENAR: Private Rx + public getter
final RxBool _isLoading = false.obs;
bool get isLoading => _isLoading.value;

// ❌ SALAH: Public Rx langsung (Page bisa ubah state dari luar)
RxBool isLoading = false.obs;  // Hindari ini

// ✅ BENAR: Update list state
_items.value = newList;          // Replace seluruh list
_items.add(newItem);             // Tambah 1 item
_items.removeWhere((i) => ...);  // Hapus berdasarkan kondisi

// ✅ BENAR: Obx hanya di widget yang perlu rebuild
Obx(() => Text('${controller.balance}')),  // ← Hanya ini yang rebuild

// ❌ SALAH: Obx di Scaffold seluruhnya (terlalu boros rebuild)
Obx(() => Scaffold(...))  // Hindari — wrap hanya bagian yang berubah
```

---

## 10. Freemium Guard Pattern

### 10.1 `PremiumController` (Global, permanent: true)

```dart
class PremiumController extends GetxController {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  PremiumController({required this.getCurrentUserUseCase});

  final RxBool _isPro = false.obs;
  bool get isPro => _isPro.value;

  final RxInt _scanQuotaRemaining = AppConstants.freeReceiptScanQuota.obs;
  int get scanQuotaRemaining => _scanQuotaRemaining.value;

  final RxInt _voiceQuotaRemaining = AppConstants.freeVoiceRecordQuota.obs;
  int get voiceQuotaRemaining => _voiceQuotaRemaining.value;

  @override
  void onInit() {
    super.onInit();
    _loadPremiumStatus();
  }

  bool canUseScan() => _isPro.value || _scanQuotaRemaining.value > 0;
  bool canUseVoice() => _isPro.value || _voiceQuotaRemaining.value > 0;
  bool canUseFeature(String featureId) {
    // featureId: 'theme_seaside_pro', 'icon_rounded_pro', 'export_excel', dll
    if (_isPro.value) return true;
    // Cek daftar fitur yang membutuhkan PRO
    return _freeFeatures.contains(featureId);
  }

  static const Set<String> _freeFeatures = {
    'theme_classic', 'theme_ocean', 'icon_default',
    'export_csv', 'card_style_gradient', 'bar_appearance_rounded',
  };
}
```

### 10.2 Penggunaan Guard di Controller Fitur

```dart
// Di ReceiptScannerController
Future<void> startScan() async {
  final premiumController = Get.find<PremiumController>();

  if (!premiumController.canUseScan()) {
    // Kuota habis — arahkan ke upgrade
    Get.bottomSheet(UpgradePremiumSheet(
      featureName: 'AI Receipt Scanner',
      reason: 'Kamu sudah menggunakan ${AppConstants.freeReceiptScanQuota} scan gratis bulan ini.',
    ));
    return;
  }

  // Lanjutkan proses scan...
}
```

### 10.3 Penggunaan Guard di Page (untuk UI element yang terkunci)

```dart
// Di ThemePickerPage
Widget _buildThemeCard(ThemeEntity theme) {
  final isPro = Get.find<PremiumController>().isPro;
  final isLocked = theme.isPremium && !isPro;

  return GestureDetector(
    onTap: () => controller.applyTheme(theme.id),
    child: Stack(
      children: [
        ThemePreviewCard(theme: theme),
        if (isLocked)
          const Positioned(
            top: 8, right: 8,
            child: Icon(Icons.lock, color: Colors.white),
          ),
      ],
    ),
  );
}
```

---

## 11. Checklist Membuat Fitur Baru

Gunakan checklist ini setiap kali membuat fitur baru. Urutannya tidak boleh dibalik.

```
☐  1. Buat folder: lib/features/{nama_fitur}/
☐  2. domain/entities/{nama}_entity.dart
       → Hanya properti + constructor. TIDAK ada fromJson/toJson.
☐  3. domain/repositories/{nama}_repository.dart
       → Abstract class. Semua method return Future<Either<Failure, Type>>.
☐  4. domain/usecases/{aksi}_{nama}_usecase.dart (1 file per operasi)
       → Params class di file yang sama.
       → implements UseCase<Type, Params> dari core/usecases/usecase.dart.
☐  5. data/models/{nama}_model.dart
       → extends Entity. Tambah fromJson, toJson, toEntity.
☐  6. data/datasources/{nama}_datasource.dart (abstract, jika implementasi TBD)
       → Buat abstract contract jika package/API belum final.
☐  7. data/datasources/{nama}_datasource_impl.dart
       → implements abstract contract. Throw Exception, bukan Failure.
☐  8. data/repositories/{nama}_repository_impl.dart
       → implements domain repository. try-catch setiap method.
       → Konversi Model → Entity via .toEntity().
☐  9. presentation/bindings/{nama}_binding.dart
       → Urutan: DataSource → Repository → UseCase → Controller.
       → Gunakan Get.lazyPut (bukan Get.put).
☐ 10. presentation/controllers/{nama}_controller.dart
       → State: private Rx + public getter.
       → result.fold() untuk semua UseCase call.
       → _loadInitialData() di onInit().
☐ 11. presentation/pages/{nama}_page.dart
       → extends GetView<Controller>.
       → Gunakan Obx() hanya untuk bagian yang reaktif.
       → Pecah widget kompleks ke presentation/widgets/.
☐ 12. core/routes/app_routes.dart → Tambah route string constant.
☐ 13. core/routes/app_pages.dart → Tambah GetPage + Binding.
☐ 14. Jika fitur punya gating PRO: tambah ID fitur ke PremiumController._freeFeatures atau
       buat logic check di controller fitur menggunakan Get.find<PremiumController>().
☐ 15. Jika fitur butuh Abstract Contract (TBD): pastikan abstract class ada di datasources/,
       implementasinya bisa di-swap hanya dengan 1 baris di Binding.
```

---

*Kembali ke: [README.md](../README.md) | [FEATURES.md](FEATURES.md) | [DATABASE.md](DATABASE.md)*
