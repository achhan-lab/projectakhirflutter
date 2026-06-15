import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/sqlite_service.dart';
import '../models/user_model.dart';

class AuthService {
  final SQLiteService _db = SQLiteService();

  Future<int> register(UserModel user) async {
    try {
      debugPrint('🔐 Starting registration for: ${user.email}');
      debugPrint('📱 Is Web: ${identical(1, 1.0) ? 'Likely Web' : 'Mobile'}');

      final now = DateTime.now().toIso8601String();
      final map = user.toMap();
      map['created_at'] = now;
      map['role'] = user.role;

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

      final rows = await _db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      debugPrint('🔍 Query result: ${rows.length} user(s) found');

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
