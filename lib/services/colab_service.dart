import '../core/database/sqlite_service.dart';
import '../models/colab_model.dart';

class ColabService {
  final SQLiteService _db = SQLiteService();

  Future<int> createColab(ColabModel colab) async {
    final now = DateTime.now().toIso8601String();
    final map = colab.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await _db.insert('colabs', map);
  }

  Future<List<ColabModel>> getAllColabs({
    String? kategori,
    String? status,
    String? search,
  }) async {
    String? where;
    List? args;

    if (search != null && search.isNotEmpty) {
      where = '(judul LIKE ? OR deskripsi LIKE ?)';
      args = ['%$search%', '%$search%'];
    }
    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      where = (where == null) ? 'kategori = ?' : '$where AND kategori = ?';
      args = (args == null) ? [kategori] : [...args, kategori];
    }
    if (status != null && status.isNotEmpty) {
      where = (where == null) ? 'status = ?' : '$where AND status = ?';
      args = (args == null) ? [status] : [...args, status];
    }

    final rows = await _db.query(
      'colabs',
      where: where,
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return rows
        .map((r) => ColabModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<ColabModel?> getColab(int id) async {
    final rows = await _db.query(
      'colabs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isNotEmpty) {
      return ColabModel.fromMap(rows.first as Map<String, dynamic>);
    }
    return null;
  }

  Future<int> updateColab(ColabModel colab) async {
    final now = DateTime.now().toIso8601String();
    final map = colab.toMap();
    map['updated_at'] = now;
    map.remove('created_at');
    return await _db.update('colabs', map, 'id = ?', [colab.id!]);
  }

  Future<int> deleteColab(int id) async {
    return await _db.delete('colabs', 'id = ?', [id]);
  }

  Future<int> joinColab(int id) async {
    final colab = await getColab(id);
    if (colab == null) return 0;
    if (colab.currentAnggota >= colab.maxAnggota) return -1; // Full
    return await _db.update(
      'colabs',
      {'current_anggota': colab.currentAnggota + 1},
      'id = ?',
      [id],
    );
  }

  Future<String> getCreatorName(int userId) async {
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

  Future<String?> getCreatorWhatsapp(int userId) async {
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
}
