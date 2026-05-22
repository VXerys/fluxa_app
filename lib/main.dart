import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/constants.dart';
import 'core/database/local_database_service.dart';
import 'core/storage/storage_service.dart';
import 'core/network/supabase_client.dart';
import 'core/di/initial_binding.dart';
import 'core/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Load environment variables from .env (local, ignored file)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Ignore when .env is missing in dev builds.
  }

  // Initialize local storage
  await StorageService.init();

  // Initialize local database
  await LocalDatabaseService.init();

  // Initialize Supabase client (reads keys from AppConstants)
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      locale: const Locale('id', 'ID'),
      supportedLocales: const <Locale>[
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(bodyMedium: AppTextStyles.roboto14w400),
        fontFamily: 'Roboto',
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
