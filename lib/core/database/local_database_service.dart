import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

class LocalDatabaseService {
  LocalDatabaseService._();

  static Database? _database;

  static Future<void> init() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, AppConstants.localDbName);

    _database = await openDatabase(
      fullPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Database get database {
    final db = _database;
    if (db == null) {
      throw Exception('Local database not initialized');
    }
    return db;
  }

  static Future<void> clearAll() async {
    final db = database;
    await db.delete('offline_queue');
    await db.delete('transactions_cache');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS offline_queue (
        id TEXT PRIMARY KEY,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        payload TEXT NOT NULL,
        status TEXT DEFAULT 'PENDING',
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions_cache (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category_id TEXT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL DEFAULT 'IDR',
        note TEXT,
        date INTEGER NOT NULL,
        time TEXT,
        is_deleted INTEGER DEFAULT 0,
        is_synced INTEGER DEFAULT 1,
        raw_json TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');
  }
}
