import '../core/database/sqlite_service.dart';
import '../models/forum_post_model.dart';

class ForumService {
  final SQLiteService _db = SQLiteService();

  Future<int> createPost(ForumPostModel post) async {
    final now = DateTime.now().toIso8601String();
    final map = post.toMap();
    map['created_at'] = now;
    return await _db.insert('forum_posts', map);
  }

  Future<List<ForumPostModel>> getAllPosts({String? kategori}) async {
    String? where;
    List? args;
    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      where = 'kategori = ?';
      args = [kategori];
    }
    final rows = await _db.query(
      'forum_posts',
      where: where,
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return rows
        .map((r) => ForumPostModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<String> getAuthorName(int userId) async {
    try {
      final rows = await _db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (rows.isNotEmpty) {
        return rows.first['nama'] as String? ?? 'Anonim';
      }
    } catch (_) {}
    return 'Anonim';
  }

  Future<String?> getAuthorWhatsapp(int userId) async {
    try {
      final rows = await _db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (rows.isNotEmpty) {
        return rows.first['no_whatsapp'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<int> deletePost(int id) async {
    return await _db.delete('forum_posts', 'id = ?', [id]);
  }
}
