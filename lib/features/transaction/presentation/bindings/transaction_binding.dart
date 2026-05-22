import 'package:get/get.dart';

import '../../../../core/sync/finance_sync_service.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
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
import '../controllers/transaction_controller.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CategoryRemoteDataSource>()) {
      Get.lazyPut<CategoryRemoteDataSource>(() => CategoryRemoteDataSourceImpl());
    }
    if (!Get.isRegistered<TransactionRemoteDataSource>()) {
      Get.lazyPut<TransactionRemoteDataSource>(
        () => TransactionRemoteDataSourceImpl(),
      );
    }

    if (!Get.isRegistered<CategoryRepository>()) {
      Get.lazyPut<CategoryRepository>(
        () => CategoryRepositoryImpl(remoteDataSource: Get.find()),
      );
    }
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut<TransactionRepository>(
        () => TransactionRepositoryImpl(remoteDataSource: Get.find()),
      );
    }

    if (!Get.isRegistered<GetCategoriesUseCase>()) {
      Get.lazyPut(() => GetCategoriesUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<GetCategoryTreeUseCase>()) {
      Get.lazyPut(() => GetCategoryTreeUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<GetParentCategoriesUseCase>()) {
      Get.lazyPut(() => GetParentCategoriesUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<GetAllSystemCategoriesUseCase>()) {
      Get.lazyPut(() => GetAllSystemCategoriesUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<AddTransactionUseCase>()) {
      Get.lazyPut(() => AddTransactionUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<GetTransactionsUseCase>()) {
      Get.lazyPut(() => GetTransactionsUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<DeleteTransactionUseCase>()) {
      Get.lazyPut(() => DeleteTransactionUseCase(repository: Get.find()));
    }
    if (!Get.isRegistered<UpdateTransactionUseCase>()) {
      Get.lazyPut(() => UpdateTransactionUseCase(Get.find()));
    }
    if (!Get.isRegistered<GetTransactionSummaryUseCase>()) {
      Get.lazyPut(() => GetTransactionSummaryUseCase(repository: Get.find()));
    }

    if (!Get.isRegistered<TransactionController>()) {
      Get.lazyPut(
        () => TransactionController(
          addTransactionUseCase: Get.find(),
          getTransactionsUseCase: Get.find(),
          deleteTransactionUseCase: Get.find(),
          updateTransactionUseCase: Get.find(),
          getTransactionSummaryUseCase: Get.find(),
          getCategoriesUseCase: Get.find(),
          getCategoryTreeUseCase: Get.find(),
          getParentCategoriesUseCase: Get.find(),
          getAllSystemCategoriesUseCase: Get.find(),
          financeSyncService: Get.find<FinanceSyncService>(),
        ),
      );
    }
  }
}
