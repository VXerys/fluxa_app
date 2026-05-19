import 'package:get/get.dart';

import '../../data/datasources/category_remote_datasource.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_transaction_summary_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../controllers/transaction_controller.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryRemoteDataSource>(() => CategoryRemoteDataSourceImpl());
    Get.lazyPut<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(),
    );

    Get.lazyPut<CategoryRepository>(
      () => CategoryRepositoryImpl(remoteDataSource: Get.find()),
    );
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(remoteDataSource: Get.find()),
    );

    Get.lazyPut(() => GetCategoriesUseCase(repository: Get.find()));
    Get.lazyPut(() => AddTransactionUseCase(repository: Get.find()));
    Get.lazyPut(() => GetTransactionsUseCase(repository: Get.find()));
    Get.lazyPut(() => DeleteTransactionUseCase(repository: Get.find()));
    Get.lazyPut(() => GetTransactionSummaryUseCase(repository: Get.find()));

    Get.lazyPut(
      () => TransactionController(
        addTransactionUseCase: Get.find(),
        getTransactionsUseCase: Get.find(),
        deleteTransactionUseCase: Get.find(),
        getTransactionSummaryUseCase: Get.find(),
        getCategoriesUseCase: Get.find(),
      ),
    );
  }
}
