import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Read values from dotenv; defaults to empty string if missing.
  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static const String appName = 'Fluxa';

  // Free tier quotas used in MVP
  static const int freeReceiptScanQuota = 5;
  static const int freeVoiceRecordQuota = 20;

  // Default locale for app
  static const String defaultLocale = 'id_ID';
}
