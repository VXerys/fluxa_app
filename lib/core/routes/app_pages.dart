import 'package:get/get.dart';

import '../../core/storage/storage_service.dart';
import '../../core/widgets/placeholder_page.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/navigation/presentation/bindings/main_navigation_binding.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../features/transaction/presentation/bindings/transaction_binding.dart';
import '../../features/transaction/presentation/pages/add_transaction_page.dart';
import '../../features/transaction/presentation/pages/transaction_list_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static String get initial {
    final token = StorageService.read<String>('access_token');
    return token != null ? Routes.main : Routes.login;
  }

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.splash,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const PlaceholderPage(
        title: 'Fluxa',
        message: 'Main page placeholder',
      ),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
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
