import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // Read values from dotenv; defaults to empty string if missing.
  // TODO: Set SUPABASE_URL and SUPABASE_ANON_KEY in .env for local dev.
  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static const String appName = 'Fluxa';
  static const String localDbName = 'fluxa_local.db';
  static const String defaultCurrency = 'IDR';

  // Free tier quotas used in MVP
  static const int freeReceiptScanQuota = 5;
  static const int freeVoiceRecordQuota = 20;

  // Default locale for app
  static const String defaultLocale = 'id_ID';
}
