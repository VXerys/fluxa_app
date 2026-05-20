import 'package:get/get.dart';

import '../../features/navigation/presentation/bindings/main_navigation_binding.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../features/transaction/presentation/bindings/transaction_binding.dart';
import '../../features/transaction/presentation/pages/add_transaction_page.dart';
import '../../features/transaction/presentation/pages/transaction_list_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = Routes.splash;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.splash,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: Routes.addTransaction,
      page: () => const AddTransactionPage(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: Routes.transactionList,
      page: () => const TransactionListPage(),
      binding: TransactionBinding(),
    ),
  ];
}
