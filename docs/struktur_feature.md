# ⚙️ Feature Layer — `lib/features/{nama_fitur}/`

> Setiap fitur mengikuti **Clean Architecture** dengan 3 layer: `domain/` → `data/` → `presentation/`.
> Dokumen ini menjelaskan **cara menulis kode** di setiap layer secara detail.

---

## 1. DOMAIN LAYER — `domain/`

Domain adalah **inti bisnis**. Layer ini **TIDAK BOLEH** mengimport package eksternal selain `dartz` (untuk `Either`). Tidak boleh import Flutter, GetX, Supabase, dsb.

### 1a. `domain/entities/` — Objek Bisnis Murni

Entity hanya berisi **properti** dan constructor. Tidak ada method `fromJson`, `toJson`, atau logic apapun.

```dart
// domain/entities/book_entity.dart

class BookEntity {
  final String id;
  final DateTime createdAt;
  final String ownerId;
  final String title;
  final String? author;
  final String? description;
  final List<String>? genre;
  final String? bookImage;
  final String? condition;
  final bool isArchive;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String status;
  final List<String> communityIds;
  final int viewCount;

  BookEntity({
    required this.id,
    required this.createdAt,
    required this.ownerId,
    required this.title,
    this.author,
    this.description,
    this.genre,
    this.bookImage,
    this.condition = 'GOOD',
    this.isArchive = false,
    required this.updatedAt,
    this.deletedAt,
    this.status = 'AVAILABLE',
    required this.communityIds,
    this.viewCount = 0,
  });
}
```

**Aturan Entity:**
- Field wajib → `required` di constructor.
- Field opsional → nullable (`String?`) atau punya default value.
- **Tidak ada** method `fromJson`/`toJson` — itu tugas Model di Data layer.

---

### 1b. `domain/repositories/` — Contract (Abstract Class)

Mendefinisikan **operasi apa saja** yang bisa dilakukan tanpa mempedulikan implementasinya.

```dart
// domain/repositories/book_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';

abstract class BookRepository {
  // CREATE
  Future<Either<Failure, BookEntity>> createBook({
    required String title,
    String? author,
    String? description,
    required List<String> communityIds,
  });

  // READ (single)
  Future<Either<Failure, BookEntity>> getBook(String bookId);

  // READ (list)
  Future<Either<Failure, List<BookEntity>>> getUserBooks();
  Future<Either<Failure, List<BookEntity>>> getBooksFromUserCommunities({
    String? genreFilter,
  });

  // UPDATE
  Future<Either<Failure, BookEntity>> updateBook({
    required String bookId,
    String? title,
    // ... field lainnya
  });

  // DELETE
  Future<Either<Failure, void>> deleteBook(String bookId);

  // ACTIONS
  Future<Either<Failure, void>> toggleBookmark(String bookId, bool isBookmarking);
  Future<Either<Failure, List<String>>> getBookmarkedBookIds();
}
```

**Aturan Repository Contract:**
- Semua method mengembalikan `Future<Either<Failure, Type>>` — konsisten tanpa pengecualian.
- Return type `void` untuk operasi yang tidak perlu mengembalikan data (delete, toggle).
- Parameter menggunakan tipe dari **Entity**, bukan Model.

---

### 1c. `domain/usecases/` — Business Logic

Setiap UseCase melakukan **satu tugas spesifik**. Ada 2 varian:

#### Varian 1: UseCase TANPA parameter (gunakan `NoParams`)
```dart
// domain/usecases/get_user_books_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class GetUserBooksUseCase implements UseCase<List<BookEntity>, NoParams> {
  final BookRepository repository;

  GetUserBooksUseCase({required this.repository});

  @override
  Future<Either<Failure, List<BookEntity>>> call(NoParams params) async {
    return await repository.getUserBooks();
  }
}
```

#### Varian 2: UseCase DENGAN parameter (buat Params class)
```dart
// domain/usecases/create_book_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

// Params class → didefinisikan di file YANG SAMA dengan UseCase-nya
class CreateBookParams {
  final String title;
  final String? author;
  final String? description;
  final List<String>? genre;
  final String? bookImagePath;
  final String? condition;
  final required List<String> communityIds;

  CreateBookParams({
    required this.title,
    this.author,
    this.description,
    this.genre,
    this.bookImagePath,
    this.condition,
    required this.communityIds,
  });
}

class CreateBookUseCase implements UseCase<BookEntity, CreateBookParams> {
  final BookRepository repository;

  CreateBookUseCase({required this.repository});

  @override
  Future<Either<Failure, BookEntity>> call(CreateBookParams params) async {
    return await repository.createBook(
      title: params.title,
      author: params.author,
      description: params.description,
      genre: params.genre,
      bookImagePath: params.bookImagePath,
      condition: params.condition,
      communityIds: params.communityIds,
    );
  }
}
```

#### Varian 3: UseCase dengan return type `void`
```dart
// domain/usecases/delete_book_usecase.dart

class DeleteBookParams {
  final String bookId;
  DeleteBookParams({required this.bookId});
}

class DeleteBookUseCase implements UseCase<void, DeleteBookParams> {
  final BookRepository repository;
  DeleteBookUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteBookParams params) async {
    return await repository.deleteBook(params.bookId);
  }
}
```

**Aturan UseCase:**
- 1 UseCase = 1 fungsi bisnis. Jangan gabung banyak operasi dalam 1 UseCase.
- Params class selalu didefinisikan di file yang sama.
- UseCase memanggil method Repository, **bukan** DataSource langsung.

---

## 2. DATA LAYER — `data/`

Data layer bertanggung jawab untuk berkomunikasi dengan dunia luar (API, database lokal, file system).

### 2a. `data/models/` — Data Model (JSON Parsing)

Model meng-**extend** Entity dan menambahkan kemampuan `fromJson` / `toJson` / `toEntity`.

```dart
// data/models/book_model.dart

import '../../domain/entities/book_entity.dart';

class BookModel extends BookEntity {
  BookModel({
    required super.id,
    required super.createdAt,
    required super.ownerId,
    required super.title,
    super.author,
    super.description,
    super.genre,
    super.bookImage,
    super.condition,
    super.isArchive,
    required super.updatedAt,
    super.deletedAt,
    super.status,
    required super.communityIds,
    super.viewCount,
  });

  // === FROM JSON (API response → Model) ===
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      description: json['description'] as String?,
      genre: json['genre'] != null
          ? List<String>.from(json['genre'] as List)
          : null,
      bookImage: json['book_image'] as String?,
      condition: json['condition'] as String? ?? 'GOOD',
      isArchive: json['is_archive'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      status: json['status'] as String? ?? 'AVAILABLE',
      communityIds: List<String>.from(json['community_ids'] as List),
      viewCount: json['view_count'] as int? ?? 0,
    );
  }

  // === TO JSON (Model → API request body) ===
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'owner_id': ownerId,
      'title': title,
      'author': author,
      'description': description,
      'genre': genre,
      'book_image': bookImage,
      'condition': condition,
      'is_archive': isArchive,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'status': status,
      'community_ids': communityIds,
      'view_count': viewCount,
    };
  }

  // === TO ENTITY (Model → Entity untuk dikirim ke Domain/Presentation) ===
  BookEntity toEntity() {
    return BookEntity(
      id: id,
      createdAt: createdAt,
      ownerId: ownerId,
      title: title,
      author: author,
      description: description,
      genre: genre,
      bookImage: bookImage,
      condition: condition,
      isArchive: isArchive,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      status: status,
      communityIds: communityIds,
      viewCount: viewCount,
    );
  }
}
```

**Aturan Model:**
- Model **extends** Entity (bukan implements).
- Constructor menggunakan `super.*` untuk forward ke parent.
- Key JSON menggunakan **snake_case** sesuai konvensi API/database.
- Property Dart menggunakan **camelCase**.
- Selalu berikan **default value** untuk field nullable di `fromJson` (misal: `?? 'GOOD'`).
- `toEntity()` wajib ada — dipakai oleh Repository untuk konversi sebelum dikirim ke Domain.

---

### 2b. `data/datasources/` — Komunikasi dengan API/Database

DataSource memiliki **abstract class** (contract) dan **implementation class** dalam file yang sama.

```dart
// data/datasources/book_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/book_model.dart';

// === CONTRACT ===
abstract class BookRemoteDataSource {
  Future<BookModel> createBook({required String title, ...});
  Future<BookModel> getBook(String bookId);
  Future<List<BookModel>> getUserBooks();
  Future<void> deleteBook(String bookId);
  // ... semua operasi
}

// === IMPLEMENTATION ===
class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final supabase = SupabaseService.client;

  @override
  Future<List<BookModel>> getUserBooks() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('book')
        .select()
        .eq('owner_id', userId)
        .isFilter('deleted_at', null)          // Soft-delete filter
        .order('created_at', ascending: false); // Newest first

    return (response as List)
        .map((json) => BookModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> deleteBook(String bookId) async {
    // Soft delete: set deleted_at instead of actually deleting
    await supabase
        .from('book')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', bookId);
  }

  // ... implementasi method lainnya
}
```

**Aturan DataSource:**
- DataSource **hanya** berurusan dengan `Model`, bukan `Entity`.
- Return type selalu `Model` atau `List<Model>` (bukan `Entity`).
- Throw **raw Exception** di sini. Repository yang akan catch dan konversi ke `Failure`.
- Selalu validasi auth (`currentUser?.id`) di awal setiap method yang memerlukan user context.
- Gunakan **soft delete** (`deleted_at`) alih-alih hard delete untuk data penting.

---

### 2c. `data/repositories/` — Implementasi Repository

Menjembatani DataSource → Domain. Tugas utamanya: **try-catch** dan konversi Model → Entity.

```dart
// data/repositories/book_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl({required this.remoteDataSource});

  // Pattern: READ single → Model.toEntity()
  @override
  Future<Either<Failure, BookEntity>> getBook(String bookId) async {
    try {
      final book = await remoteDataSource.getBook(bookId);
      return Right(book.toEntity());   // ← Model → Entity conversion
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Pattern: READ list → map setiap Model ke Entity
  @override
  Future<Either<Failure, List<BookEntity>>> getUserBooks() async {
    try {
      final books = await remoteDataSource.getUserBooks();
      return Right(books.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Pattern: DELETE / void action → Right(null)
  @override
  Future<Either<Failure, void>> deleteBook(String bookId) async {
    try {
      await remoteDataSource.deleteBook(bookId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

**Aturan Repository Impl:**
- Setiap method di-wrap dengan `try-catch`.
- `catch (e)` → selalu return `Left(ServerFailure(e.toString()))`.
- Konversi `Model → Entity` dilakukan di sini via `.toEntity()`.
- Untuk operasi void: return `const Right(null)`.

---

## 3. PRESENTATION LAYER — `presentation/`

### 3a. `presentation/bindings/` — Dependency Injection per Fitur

Binding mendaftarkan DataSource → Repository → UseCase → Controller secara berurutan.

```dart
// presentation/bindings/book_binding.dart

import 'package:get/get.dart';
// ... import semua dependency

class BookBinding extends Bindings {
  @override
  void dependencies() {
    // 1. DataSources
    Get.lazyPut<BookRemoteDataSource>(() => BookRemoteDataSourceImpl());

    // 2. Repositories
    Get.lazyPut(() => BookRepositoryImpl(remoteDataSource: Get.find()));

    // 3. UseCases
    Get.lazyPut(() => CreateBookUseCase(repository: Get.find<BookRepositoryImpl>()));
    Get.lazyPut(() => DeleteBookUseCase(repository: Get.find<BookRepositoryImpl>()));
    Get.lazyPut(() => GetUserBooksUseCase(repository: Get.find<BookRepositoryImpl>()));

    // 4. Controllers
    Get.lazyPut(() => BookController(
      createBookUseCase: Get.find(),
      deleteBookUseCase: Get.find(),
      getUserBooksUseCase: Get.find(),
    ));
  }
}
```

**Aturan Binding:**
- Urutan registrasi: **DataSource → Repository → UseCase → Controller**.
- Gunakan `Get.lazyPut` (bukan `Get.put`) — di-instansiasi hanya saat pertama kali dipanggil.
- Untuk dependency cross-fitur, gunakan guard: `if (!Get.isRegistered<Type>()) { Get.lazyPut(...) }`.
- Binding composite (seperti `MainNavigationBinding`) boleh memanggil `.dependencies()` dari binding fitur lain.

---

### 3b. `presentation/controllers/` — State Management & Logic UI

Controller memegang **state** (variabel reaktif) dan memanggil **UseCase** untuk operasi bisnis.

```dart
// presentation/controllers/book_controller.dart

import 'package:get/get.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/create_book_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';

class BookController extends GetxController {
  // === Inject UseCases via constructor ===
  final CreateBookUseCase createBookUseCase;
  final DeleteBookUseCase deleteBookUseCase;

  BookController({
    required this.createBookUseCase,
    required this.deleteBookUseCase,
  });

  // === Reactive State ===
  final RxList<BookEntity> _books = <BookEntity>[].obs;
  List<BookEntity> get books => _books;         // Public getter

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;       // Public getter

  // === Lifecycle ===
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();   // Load data saat controller pertama kali dibuat
  }

  Future<void> _loadInitialData() async {
    _isLoading.value = true;
    try {
      await Future.wait([    // Parallel loading untuk performa
        loadBooks(),
      ]);
    } finally {
      _isLoading.value = false;
    }
  }

  // === Business Operations ===
  Future<void> loadBooks() async {
    final result = await getUserBooksUseCase(NoParams());

    result.fold(
      (failure) {                          // Left → Error
        Get.snackbar('Error', failure.message);
        _books.clear();
      },
      (books) {                            // Right → Success
        _books.value = books;
      },
    );
  }

  Future<void> deleteBook(String bookId) async {
    final result = await deleteBookUseCase(DeleteBookParams(bookId: bookId));

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (_) {
        _books.removeWhere((b) => b.id == bookId);  // Update local state
        Get.snackbar('Success', 'Book deleted!');
      },
    );
  }
}
```

**Aturan Controller:**
- State menggunakan **Rx types** (`RxList`, `RxBool`, `Rx<Type?>`).
- State variable → **private** (`_books`), akses via **public getter** (`get books`).
- `result.fold()` → selalu handle **kedua sisi** (Left/failure & Right/success).
- Untuk optimistic update (UX lebih responsif):
  ```dart
  // 1. Update UI dulu
  bookmarkedIds.add(bookId);
  // 2. Call API
  final result = await useCase(params);
  // 3. Jika gagal, revert
  result.fold(
    (failure) => bookmarkedIds.remove(bookId), // Revert
    (success) { /* sudah terupdate */ },
  );
  ```

---

### 3c. `presentation/pages/` — UI Layer (Ringkas)

Page menggunakan `GetView<ControllerType>` dan hanya berisi layout UI. Tidak ada business logic.

```dart
class BookListPage extends GetView<BookController> {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) return const Center(child: CircularProgressIndicator());
        if (controller.books.isEmpty) return const Center(child: Text('No books'));
        return ListView.builder(
          itemCount: controller.books.length,
          itemBuilder: (_, i) => BookCard(book: controller.books[i]),
        );
      }),
    );
  }
}
```

**Aturan Page:**
- Extend `GetView<Controller>` → otomatis punya `controller` property.
- Gunakan `Obx(() => ...)` untuk widget yang perlu rebuild saat state berubah.
- Pecah widget kompleks ke file terpisah di `widgets/`.

---

## Checklist Membuat Fitur Baru

```text
☐  1. Buat folder: lib/features/{nama_fitur}/
☐  2. domain/entities/{nama}_entity.dart     → Definisi properti bisnis
☐  3. domain/repositories/{nama}_repository.dart → Abstract class (contract)
☐  4. domain/usecases/{aksi}_{nama}_usecase.dart → 1 usecase per operasi
☐  5. data/models/{nama}_model.dart          → extends Entity + fromJson/toJson/toEntity
☐  6. data/datasources/{nama}_remote_datasource.dart → Abstract + Impl
☐  7. data/repositories/{nama}_repository_impl.dart → implements contract, try-catch
☐  8. presentation/bindings/{nama}_binding.dart → DI: DS→Repo→UC→Controller
☐  9. presentation/controllers/{nama}_controller.dart → State + call UseCases
☐ 10. presentation/pages/{nama}_page.dart    → UI (GetView)
☐ 11. presentation/widgets/                  → Widget pecahan
☐ 12. core/routes/app_routes.dart            → Tambah route string
☐ 13. core/routes/app_pages.dart             → Tambah GetPage + binding
```
