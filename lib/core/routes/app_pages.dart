import 'package:get/get.dart';

import '../../features/navigation/presentation/bindings/main_navigation_binding.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../widgets/placeholder_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = Routes.splash;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.splash,
      page: () =>
          const PlaceholderPage(title: 'Fluxa', message: 'Foundation ready'),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: Routes.addTransaction,
      page: () => const PlaceholderPage(
        title: 'Tambah Transaksi',
        message: 'Add transaction UI pending',
      ),
    ),
    GetPage(
      name: Routes.transactionList,
      page: () => const PlaceholderPage(
        title: 'Transaksi',
        message: 'Transaction list UI pending',
      ),
    ),
  ];
}
