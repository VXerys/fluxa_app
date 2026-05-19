import 'package:get/get.dart';

import '../widgets/placeholder_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = Routes.splash;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.splash,
      page: () => const PlaceholderPage(
        title: 'Fluxa',
        message: 'Foundation ready',
      ),
    ),
    GetPage(
      name: Routes.transactions,
      page: () => const PlaceholderPage(
        title: 'Transactions',
        message: 'Transaction UI pending',
      ),
    ),
  ];
}
