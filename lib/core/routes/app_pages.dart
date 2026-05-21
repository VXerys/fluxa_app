import 'package:get/get.dart';

import '../../core/storage/storage_service.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/navigation/presentation/bindings/main_navigation_binding.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/tampilan_kartu_page.dart';
import '../../features/profile/presentation/pages/tampilan_menu_page.dart';
import '../../features/profile/presentation/pages/profile_detail_placeholder_page.dart';
import '../../features/transaction/presentation/bindings/transaction_binding.dart';
import '../../features/transaction/presentation/pages/add_transaction_page.dart';
import '../../features/transaction/presentation/pages/transaction_list_page.dart';
import '../../features/wallet/presentation/bindings/wallet_binding.dart';
import '../widgets/placeholder_page.dart';
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
      page: () => const MainNavigationPage(),
      binding: MainNavigationBinding(),
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
      transition: Transition.noTransition,
      opaque: false,
      fullscreenDialog: true,
    ),
    GetPage(
      name: Routes.transactionList,
      page: () => const TransactionListPage(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: Routes.walletDetail,
      page: () => const PlaceholderPage(
        title: 'Detail Dompet',
        message: 'Halaman detail dompet segera hadir',
      ),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfilePage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.tampilanKartu,
      page: () => const TampilanKartuPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.tampilanMenu,
      page: () => const TampilanMenuPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.imporData,
      page: () => const ImporDataPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.periodePencatatan,
      page: () => const PeriodePencatatanPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.kategori,
      page: () => const KategoriPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.pengaturanDompet,
      page: () => const PengaturanDompetPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.tema,
      page: () => const TemaPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.urutanMenu,
      page: () => const UrutanMenuPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.urutanStatistik,
      page: () => const UrutanSectionStatistikPage(),
      binding: AuthBinding(),
    ),
  ];
}
