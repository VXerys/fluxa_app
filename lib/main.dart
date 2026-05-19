import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/constants.dart';
import 'core/storage/storage_service.dart';
import 'core/network/supabase_client.dart';
import 'core/di/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env (local, ignored file)
  await dotenv.load(fileName: '.env');

  // Initialize local storage
  await StorageService.init();

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(bodyMedium: AppTextStyles.roboto14w400),
        fontFamily: 'Roboto',
      ),
      home: const MyHomePage(title: AppConstants.appName),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.roboto16w400),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Fluxa — Basic MVP', style: AppTextStyles.lora24w400),
      ),
    );
  }
}
