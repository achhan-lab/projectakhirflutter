import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/sqlite_service.dart';
import '../models/user_model.dart';

class AuthService {
  final SQLiteService _db = SQLiteService();

  /// Simple password hashing using FNV-1a (no external package needed)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    int hash = 0x811c9dc5;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  Future<int> register(UserModel user) async {
    try {
      debugPrint('🔐 Starting registration for: ${user.email}');

      final now = DateTime.now().toIso8601String();
      final map = user.toMap();
      map['created_at'] = now;
      map['role'] = user.role;
      // Hash password before storing
      map['password'] = hashPassword(user.password);

      debugPrint('📝 User data to insert: $map');

      final id = await _db.insert('users', map);
      debugPrint('✅ Registration successful! User ID: $id');

      // Debug: Verify data was saved
      await _db.debugShowAllUsers();

      return id;
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<UserModel?> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    try {
      debugPrint('🔑 Attempting login with email: $email');

      final hashedPassword = hashPassword(password);

      // First try with hashed password (new accounts)
      var rows = await _db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );

      // If not found, try with plain text password (old accounts - backward compatibility)
      if (rows.isEmpty) {
        rows = await _db.query(
          'users',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password],
        );

        // If found with plain text, update to hashed password
        if (rows.isNotEmpty) {
          final user = UserModel.fromMap(rows.first as Map<String, dynamic>);
          if (user.id != null) {
            await _db.update(
              'users',
              {'password': hashedPassword},
              'id = ?',
              [user.id],
            );
            debugPrint(' Migrated password to hashed version for user: ${user.nama}');
          }
        }
      }

      debugPrint(' Query result: ${rows.length} user(s) found');

      if (rows.isEmpty) {
        debugPrint('❌ Login failed: No user found');
        return null;
      }

      final user = UserModel.fromMap(rows.first as Map<String, dynamic>);
      debugPrint('✅ Login successful for: ${user.nama}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id ?? 0);

      if (remember) {
        await prefs.setBool('remember_login', true);
      }

      return user;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');

      debugPrint('🔍 Getting current user with ID: $id');

      if (id == null) {
        debugPrint('ℹ️ No user logged in');
        return null;
      }

      final rows = await _db.query('users', where: 'id = ?', whereArgs: [id]);

      if (rows.isEmpty) {
        debugPrint('❌ User not found in database');
        return null;
      }

      final user = UserModel.fromMap(rows.first as Map<String, dynamic>);
      debugPrint('✅ Current user: ${user.nama}');

      return user;
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('remember_login');
      debugPrint('✅ Logged out successfully');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      rethrow;
    }
  }
}
