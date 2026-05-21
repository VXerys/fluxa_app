import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_summary_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_all_system_categories_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_category_tree_usecase.dart';
import '../../domain/usecases/get_parent_categories_usecase.dart';
import '../../domain/usecases/get_transaction_summary_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class TransactionController extends GetxController {
  final AddTransactionUseCase addTransactionUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final GetTransactionSummaryUseCase getTransactionSummaryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetCategoryTreeUseCase getCategoryTreeUseCase;
  final GetParentCategoriesUseCase getParentCategoriesUseCase;
  final GetAllSystemCategoriesUseCase getAllSystemCategoriesUseCase;

  TransactionController({
    required this.addTransactionUseCase,
    required this.getTransactionsUseCase,
    required this.deleteTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.getTransactionSummaryUseCase,
    required this.getCategoriesUseCase,
    required this.getCategoryTreeUseCase,
    required this.getParentCategoriesUseCase,
    required this.getAllSystemCategoriesUseCase,
  });

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  final RxBool _isCategoryLoading = false.obs;
  bool get isCategoryLoading => _isCategoryLoading.value;

  // True only when user has explicitly tapped a category.
  // Auto-select on load does NOT set this — prevents submitting
  // with a category the user never consciously chose.
  final RxBool _categoryConfirmedByUser = false.obs;
  bool get categoryConfirmedByUser => _categoryConfirmedByUser.value;

  final RxList<TransactionEntity> _transactions = <TransactionEntity>[].obs;
  List<TransactionEntity> get transactions => _transactions;

  final RxList<CategoryEntity> _categories = <CategoryEntity>[].obs;
  List<CategoryEntity> get categories => _categories;

  final RxList<CategoryEntity> _parentCategories = <CategoryEntity>[].obs;
  List<CategoryEntity> get parentCategories => _parentCategories;

  final RxList<CategoryEntity> _childCategories = <CategoryEntity>[].obs;
  List<CategoryEntity> get childCategories => _childCategories;

  final Rx<CategoryEntity?> _selectedParentCategory = Rx<CategoryEntity?>(null);
  CategoryEntity? get selectedParentCategory => _selectedParentCategory.value;

  final Rx<CategoryEntity?> _selectedChildCategory = Rx<CategoryEntity?>(null);
  CategoryEntity? get selectedChildCategory => _selectedChildCategory.value;

  final RxList<CategoryEntity> _filterCategories = <CategoryEntity>[].obs;
  List<CategoryEntity> get filterCategories => _filterCategories;
  List<CategoryEntity> get filterCategoriesList => _filterCategories;

  final Rx<TransactionSummaryEntity?> _summary = Rx<TransactionSummaryEntity?>(
    null,
  );
  TransactionSummaryEntity? get summary => _summary.value;

  final RxString _selectedType = 'expense'.obs;
  String get selectedType => _selectedType.value;

  CategoryEntity? get selectedCategory {
    if (!_categoryConfirmedByUser.value) return null;
    return _selectedChildCategory.value ?? _selectedParentCategory.value;
  }

  String? get resolvedSelectedCategoryId {
    if (!_categoryConfirmedByUser.value) return null;
    return _selectedChildCategory.value?.id ??
        _selectedParentCategory.value?.id;
  }

  final RxString _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;

  // Filters for Transaction Log
  final RxString _filterType = 'Semua'.obs;
  String get filterType => _filterType.value;

  final Rx<CategoryEntity?> _filterCategory = Rx<CategoryEntity?>(null);
  CategoryEntity? get filterCategory => _filterCategory.value;

  final RxString _filterDateRange = 'Semua Waktu'.obs;
  String get filterDateRange => _filterDateRange.value;

  final RxString _filterSortBy = 'Tanggal (Terbaru)'.obs;
  String get filterSortBy => _filterSortBy.value;

  final RxString _filterNominal = 'Rentang Nominal'.obs;
  String get filterNominal => _filterNominal.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  List<CategoryEntity> get visibleFilterCategories {
    final selectedFilterType = switch (_filterType.value) {
      'Pemasukan' => 'income',
      'Pengeluaran' => 'expense',
      _ => null,
    };

    if (selectedFilterType == null) return _filterCategories;
    return _filterCategories
        .where((category) => category.type == selectedFilterType)
        .toList();
  }

  void setFilterType(String val) {
    _filterType.value = val;
    final selectedFilterType = switch (val) {
      'Pemasukan' => 'income',
      'Pengeluaran' => 'expense',
      _ => null,
    };
    if (selectedFilterType != null &&
        _filterCategory.value?.type != selectedFilterType) {
      _filterCategory.value = null;
    }
    loadTransactions();
  }

  void setFilterCategory(CategoryEntity? val) {
    _filterCategory.value = val;
    loadTransactions();
  }

  void setFilterDateRange(String val) {
    _filterDateRange.value = val;
    loadTransactions();
  }

  void setFilterSortBy(String val) {
    _filterSortBy.value = val;
    loadTransactions();
  }

  void setFilterNominal(String val) {
    _filterNominal.value = val;
    loadTransactions();
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading.value = true;
    try {
      await Future.wait([
        loadCategoryTree(type: _selectedType.value),
        loadFilterCategories(),
        loadTransactions(),
        loadSummary(),
      ]);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadFilterCategories() async {
    final result = await getAllSystemCategoriesUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        _filterCategories.clear();
      },
      (categories) {
        _filterCategories.value = categories;
      },
    );
  }

  Future<void> loadCategories({String? type}) async {
    await loadCategoryTree(type: type ?? _selectedType.value);
  }

  /// Loads only parent system categories (parent_id IS NULL) for the given type.
  /// Does NOT auto-select any category — user must explicitly choose.
  Future<void> loadParentCategories({required String type}) async {
    _isCategoryLoading.value = true;
    try {
      final result = await getParentCategoriesUseCase(
        GetParentCategoriesParams(type: type),
      );

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          _parentCategories.clear();
          _categories.clear();
          _childCategories.clear();
          _selectedParentCategory.value = null;
          _selectedChildCategory.value = null;
          debugPrint(
            '[CategoryCtrl] Error loading $type categories: ${failure.message}',
          );
        },
        (categories) {
          _parentCategories.value = categories;
          _categories.value = categories;
          _childCategories.clear();
          _selectedParentCategory.value = null;
          _selectedChildCategory.value = null;
          debugPrint(
            '[CategoryCtrl] Loaded ${categories.length} $type parent categories',
          );
        },
      );
    } finally {
      _isCategoryLoading.value = false;
    }
  }

  Future<void> loadCategoryTree({required String type}) async {
    _isCategoryLoading.value = true;
    try {
      final result = await getCategoryTreeUseCase(
        GetCategoryTreeParams(type: type),
      );

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          _categories.clear();
          _parentCategories.clear();
          _childCategories.clear();
          _selectedParentCategory.value = null;
          _selectedChildCategory.value = null;
          debugPrint(
            '[CategoryCtrl] Error loading $type category tree: ${failure.message}',
          );
          Get.snackbar('Error', failure.message);
        },
        (categories) {
          _categories.value = categories;
          _parentCategories.value = categories;
          _categoryConfirmedByUser.value = false;
          debugPrint(
            '[CategoryCtrl] Loaded ${categories.length} $type parent categories (with children)',
          );
          if (categories.isNotEmpty) {
            // Auto-select first parent VISUALLY so subcategory chips show
            // immediately — does NOT mark category as confirmed for submit.
            _autoSelectFirstParent(categories.first);
          }
        },
      );
    } finally {
      _isCategoryLoading.value = false;
    }
  }

  Future<void> loadTransactions() async {
    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    if (_filterDateRange.value == 'Hari Ini') {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = startDate.add(const Duration(days: 1));
    } else if (_filterDateRange.value == 'Minggu Ini') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      endDate = startDate.add(const Duration(days: 7));
    } else if (_filterDateRange.value == 'Bulan Ini') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 1);
    }

    String? sortByParam;
    if (_filterSortBy.value == 'Tanggal (Terlama)') {
      sortByParam = 'dateAsc';
    } else if (_filterSortBy.value == 'Nominal Tertinggi') {
      sortByParam = 'amountDesc';
    } else if (_filterSortBy.value == 'Nominal Terendah') {
      sortByParam = 'amountAsc';
    } else {
      sortByParam = 'dateDesc';
    }

    double? minAmount;
    double? maxAmount;
    if (_filterNominal.value == '< 50.000') {
      maxAmount = 50000;
    } else if (_filterNominal.value == '50.000 - 100.000') {
      minAmount = 50000;
      maxAmount = 100000;
    } else if (_filterNominal.value == '> 100.000') {
      minAmount = 100000;
    }

    final params = GetTransactionsParams(
      type: switch (_filterType.value) {
        'Pemasukan' => 'income',
        'Pengeluaran' => 'expense',
        _ => null,
      },
      categoryId: _filterCategory.value?.id,
      startDate: startDate,
      endDate: endDate,
      sortBy: sortByParam,
      minAmount: minAmount,
      maxAmount: maxAmount,
    );

    final result = await getTransactionsUseCase(params);

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        _transactions.clear();
        Get.snackbar('Error', failure.message);
      },
      (transactions) {
        _transactions.value = transactions;
      },
    );
  }

  Future<void> loadSummary() async {
    final result = await getTransactionSummaryUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        _summary.value = null;
        Get.snackbar('Error', failure.message);
      },
      (summary) {
        _summary.value = summary;
      },
    );
  }

  Future<bool> addTransaction({
    required String type,
    required double amount,
    String? categoryId,
    String? note,
    required DateTime date,
    String? time,
  }) async {
    if (_isSubmitting.value) return false;
    _errorMessage.value = '';
    if (amount <= 0) {
      _errorMessage.value = 'Amount must be greater than 0';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    }

    final resolvedCategoryId = categoryId ?? resolvedSelectedCategoryId;
    if (resolvedCategoryId == null || resolvedCategoryId.isEmpty) {
      _errorMessage.value = 'Pilih kategori terlebih dahulu';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    }

    _isSubmitting.value = true;
    try {
      final params = AddTransactionParams(
        type: type,
        amount: amount,
        categoryId: resolvedCategoryId,
        note: note,
        date: date,
        time: time,
      );

      final result = await addTransactionUseCase(params);
      return await result.fold(
        (failure) async {
          _errorMessage.value = failure.message;
          Get.snackbar('Error', failure.message);
          return false;
        },
        (_) async {
          await loadTransactions();
          await loadSummary();

          if (Get.isRegistered<HomeController>()) {
            await Get.find<HomeController>().loadSummary();
          }

          _errorMessage.value = '';
          Get.snackbar('Success', 'Transaction added');
          return true;
        },
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  Future<void> deleteTransaction(String id) async {
    final result = await deleteTransactionUseCase(
      DeleteTransactionParams(transactionId: id),
    );

    await result.fold(
      (failure) async {
        _errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (_) async {
        await loadTransactions();
        await loadSummary();
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().loadSummary();
        }
        Get.snackbar('Success', 'Transaction deleted');
      },
    );
  }

  Future<bool> updateTransaction({
    required String id,
    required String type,
    required double amount,
    String? categoryId,
    String? note,
    required DateTime date,
    String? time,
  }) async {
    if (_isSubmitting.value) return false;
    _errorMessage.value = '';
    if (amount <= 0) {
      _errorMessage.value = 'Amount must be greater than 0';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    }

    final resolvedCategoryId = categoryId ?? resolvedSelectedCategoryId;
    if (resolvedCategoryId == null || resolvedCategoryId.isEmpty) {
      _errorMessage.value = 'Pilih kategori terlebih dahulu';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    }

    _isSubmitting.value = true;
    try {
      final params = UpdateTransactionParams(
        id: id,
        type: type,
        amount: amount,
        categoryId: resolvedCategoryId,
        note: note,
        date: date,
        time: time,
      );

      final result = await updateTransactionUseCase(params);
      return await result.fold(
        (failure) async {
          _errorMessage.value = failure.message;
          Get.snackbar('Error', failure.message);
          return false;
        },
        (_) async {
          await loadTransactions();
          await loadSummary();

          if (Get.isRegistered<HomeController>()) {
            await Get.find<HomeController>().loadSummary();
          }

          _errorMessage.value = '';
          Get.snackbar('Success', 'Transaction updated');
          return true;
        },
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  Future<void> changeType(String type) async {
    if (type != 'income' && type != 'expense') {
      _errorMessage.value = 'Invalid transaction type';
      Get.snackbar('Error', _errorMessage.value);
      return;
    }
    if (_selectedType.value == type && _parentCategories.isNotEmpty) return;
    _selectedType.value = type;
    _selectedParentCategory.value = null;
    _selectedChildCategory.value = null;
    _categoryConfirmedByUser.value = false;
    _categories.clear();
    _parentCategories.clear();
    _childCategories.clear();
    await loadCategoryTree(type: type);
  }

  void selectCategory(CategoryEntity category) {
    if (category.parentId == null) {
      selectParentCategory(category);
      return;
    }
    selectChildCategory(category);
  }

  /// Auto-select parent for visual purposes only (shows subcategory chips).
  /// Does NOT set [_categoryConfirmedByUser] — submit validation stays blocked.
  void _autoSelectFirstParent(CategoryEntity category) {
    _selectedParentCategory.value = category;
    _selectedChildCategory.value = null;
    _childCategories.value = category.children;
  }

  /// Called when user explicitly taps a parent category.
  void selectParentCategory(CategoryEntity category) {
    _selectedParentCategory.value = category;
    _selectedChildCategory.value = null;
    _childCategories.value = category.children;
    _categoryConfirmedByUser.value = true;
  }

  /// Called when user explicitly taps a subcategory chip.
  void selectChildCategory(CategoryEntity category) {
    _selectedChildCategory.value = category;
    _categoryConfirmedByUser.value = true;
  }

  Future<void> selectCategoryById(String? categoryId) async {
    if (categoryId == null || categoryId.isEmpty) return;

    for (final parent in _parentCategories) {
      if (parent.id == categoryId) {
        selectParentCategory(parent);
        return;
      }

      final child = parent.children.firstWhereOrNull(
        (category) => category.id == categoryId,
      );
      if (child != null) {
        selectParentCategory(parent);
        selectChildCategory(child);
        return;
      }
    }

    final result = await getCategoriesUseCase(
      GetCategoriesParams(type: _selectedType.value),
    );
    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
      },
      (categories) {
        final category = categories.firstWhereOrNull(
          (item) => item.id == categoryId,
        );
        final parentId = category?.parentId;
        if (category == null || parentId == null) return;

        final parent = _parentCategories.firstWhereOrNull(
          (item) => item.id == parentId,
        );
        if (parent == null) return;
        selectParentCategory(parent);
        selectChildCategory(category);
      },
    );
  }
}
