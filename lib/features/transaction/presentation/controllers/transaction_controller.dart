import 'package:get/get.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_summary_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_transaction_summary_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class TransactionController extends GetxController {
  final AddTransactionUseCase addTransactionUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final GetTransactionSummaryUseCase getTransactionSummaryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  TransactionController({
    required this.addTransactionUseCase,
    required this.getTransactionsUseCase,
    required this.deleteTransactionUseCase,
    required this.getTransactionSummaryUseCase,
    required this.getCategoriesUseCase,
  });

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  final RxList<TransactionEntity> _transactions = <TransactionEntity>[].obs;
  List<TransactionEntity> get transactions => _transactions;

  final RxList<CategoryEntity> _categories = <CategoryEntity>[].obs;
  List<CategoryEntity> get categories => _categories;

  final Rx<TransactionSummaryEntity?> _summary = Rx<TransactionSummaryEntity?>(
    null,
  );
  TransactionSummaryEntity? get summary => _summary.value;

  final RxString _selectedType = 'expense'.obs;
  String get selectedType => _selectedType.value;

  final Rx<CategoryEntity?> _selectedCategory = Rx<CategoryEntity?>(null);
  CategoryEntity? get selectedCategory => _selectedCategory.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading.value = true;
    try {
      await Future.wait([
        loadCategories(type: _selectedType.value),
        loadTransactions(),
        loadSummary(),
      ]);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadCategories({String? type}) async {
    final result = await getCategoriesUseCase(
      GetCategoriesParams(type: type ?? _selectedType.value),
    );

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        _categories.clear();
        Get.snackbar('Error', failure.message);
      },
      (categories) {
        _categories.value = categories;
      },
    );
  }

  Future<void> loadTransactions() async {
    final result = await getTransactionsUseCase(const NoParams());

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

    final resolvedCategoryId = categoryId ?? _selectedCategory.value?.id;
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
        Get.snackbar('Success', 'Transaction deleted');
      },
    );
  }

  void changeType(String type) {
    if (type != 'income' && type != 'expense') {
      _errorMessage.value = 'Invalid transaction type';
      Get.snackbar('Error', _errorMessage.value);
      return;
    }
    _selectedType.value = type;
    _selectedCategory.value = null;
    loadCategories(type: type);
  }

  void selectCategory(CategoryEntity category) {
    _selectedCategory.value = category;
  }
}
