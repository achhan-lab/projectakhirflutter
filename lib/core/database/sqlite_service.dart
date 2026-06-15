import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  factory SQLiteService() => _instance;
  SQLiteService._internal();

  Database? _db;
  final Map<String, List<Map<String, dynamic>>> _inMemoryTables = {
    'users': [],
    'products': [],
    'product_images': [],
    'forum_posts': [],
  };

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final isWeb = kIsWeb;
    if (isWeb) {
      throw UnimplementedError('Use inMemory methods for web');
    }

    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'samba.db');

      debugPrint('📁 Database path: $path');

      final database = await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      debugPrint('✅ Database initialized successfully');
      return database;
    } catch (e) {
      debugPrint('❌ Error initializing database: $e');
      rethrow;
    }
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    debugPrint('📝 Creating database tables...');

    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          no_whatsapp TEXT NOT NULL,
          foto_profil TEXT,
          role TEXT DEFAULT 'user',
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          nama_produk TEXT NOT NULL,
          harga INTEGER NOT NULL,
          stok INTEGER DEFAULT 0,
          kategori TEXT,
          deskripsi TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS product_images(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER NOT NULL,
          image_path TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS forum_posts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          content TEXT NOT NULL,
          kategori TEXT DEFAULT 'Diskusi',
          likes INTEGER DEFAULT 0,
          comments INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');

      debugPrint('✅ All tables created successfully');
    } catch (e) {
      debugPrint('❌ Error creating tables: $e');
      rethrow;
    }
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Upgrading database from v$oldVersion to v$newVersion');
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS forum_posts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          content TEXT NOT NULL,
          kategori TEXT DEFAULT 'Diskusi',
          likes INTEGER DEFAULT 0,
          comments INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE products ADD COLUMN stok INTEGER DEFAULT 0');
    }
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    try {
      if (kIsWeb) {
        return _insertInMemory(table, values);
      }
      final database = await db;
      final result = await database.insert(table, values);
      debugPrint('✅ [$table] Inserted id: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error inserting into $table: $e');
      rethrow;
    }
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    String? where,
    List? whereArgs,
    String? orderBy,
  }) async {
    try {
      if (kIsWeb) {
        return _queryInMemory(
          table,
          where: where,
          whereArgs: whereArgs,
          orderBy: orderBy,
        );
      }
      final database = await db;
      final result = await database.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );
      debugPrint('✅ [$table] Query found ${result.length} rows');
      return result;
    } catch (e) {
      debugPrint('❌ Error querying $table: $e');
      rethrow;
    }
  }

  Future<int> update(
    String table,
    Map<String, Object?> values,
    String where,
    List whereArgs,
  ) async {
    try {
      if (kIsWeb) {
        return _updateInMemory(table, values, where, whereArgs);
      }
      final database = await db;
      final result = await database.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
      );
      debugPrint('✅ [$table] Updated $result rows');
      return result;
    } catch (e) {
      debugPrint('❌ Error updating $table: $e');
      rethrow;
    }
  }

  Future<int> delete(String table, String where, List whereArgs) async {
    try {
      if (kIsWeb) {
        return _deleteInMemory(table, where, whereArgs);
      }
      final database = await db;
      final result = await database.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      debugPrint('✅ [$table] Deleted $result rows');
      return result;
    } catch (e) {
      debugPrint('❌ Error deleting from $table: $e');
      rethrow;
    }
  }

  // Debugging helper
  Future<void> debugShowAllUsers() async {
    try {
      if (kIsWeb) {
        debugPrint('📊 In-memory users: ${_inMemoryTables['users']}');
        return;
      }
      final database = await db;
      final users = await database.query('users');
      debugPrint('📊 Database users: $users');
    } catch (e) {
      debugPrint('❌ Error fetching users: $e');
    }
  }

  int _nextId(String table) {
    if (_inMemoryTables[table]?.isEmpty ?? true) return 1;
    final ids = _inMemoryTables[table]!
        .map((e) => e['id'] as int? ?? 0)
        .toList();
    return (ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b)) + 1;
  }

  int _insertInMemory(String table, Map<String, Object?> values) {
    final id = _nextId(table);
    values['id'] = id;
    _inMemoryTables[table]?.add(values.cast<String, dynamic>());
    return id;
  }

  List<Map<String, Object?>> _queryInMemory(
    String table, {
    String? where,
    List? whereArgs,
    String? orderBy,
  }) {
    var results = List<Map<String, dynamic>>.from(_inMemoryTables[table] ?? []);

    if (where != null && whereArgs != null) {
      results = results.where((row) {
        final parts = where.split(' AND ');
        for (int i = 0; i < parts.length; i++) {
          final part = parts[i].trim();
          final field = part.split('=')[0].trim();
          final val = whereArgs[i];
          if (row[field] != val) return false;
        }
        return true;
      }).toList();
    }

    if (orderBy != null) {
      final parts = orderBy.split(' ');
      final field = parts[0];
      results.sort((a, b) {
        final aVal = a[field];
        final bVal = b[field];
        if (aVal == null || bVal == null) return 0;
        if (parts.length > 1 && parts[1] == 'DESC') {
          return (bVal as Comparable).compareTo(aVal);
        }
        return (aVal as Comparable).compareTo(bVal);
      });
    }
    return results.cast<Map<String, Object?>>();
  }

  int _updateInMemory(
    String table,
    Map<String, Object?> values,
    String where,
    List whereArgs,
  ) {
    int count = 0;
    final rows = _inMemoryTables[table];
    if (rows != null) {
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        final parts = where.split(' AND ');
        bool matches = true;
        for (int j = 0; j < parts.length; j++) {
          final field = parts[j].trim().split('=')[0].trim();
          if (row[field] != whereArgs[j]) {
            matches = false;
            break;
          }
        }
        if (matches) {
          rows[i].addAll(values.cast<String, dynamic>());
          count++;
        }
      }
    }
    return count;
  }

  int _deleteInMemory(String table, String where, List whereArgs) {
    final rows = _inMemoryTables[table];
    if (rows == null) return 0;
    final before = rows.length;
    rows.removeWhere((row) {
      final parts = where.split(' AND ');
      for (int i = 0; i < parts.length; i++) {
        final field = parts[i].trim().split('=')[0].trim();
        if (row[field] != whereArgs[i]) return false;
      }
      return true;
    });
    return before - rows.length;
  }
}
