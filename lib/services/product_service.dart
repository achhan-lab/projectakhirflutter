import '../core/database/sqlite_service.dart';
import '../models/product_model.dart';
import '../models/product_image_model.dart';

class ProductService {
  final SQLiteService _db = SQLiteService();

  Future<int> addProduct(ProductModel p) async {
    final now = DateTime.now().toIso8601String();
    final map = p.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await _db.insert('products', map);
  }

  Future<List<ProductModel>> getAllProducts({
    String? search,
    String? kategori,
    String? orderBy,
  }) async {
    String? where;
    List? args;
    if (search != null && search.isNotEmpty) {
      where = 'nama_produk LIKE ?';
      args = ['%$search%'];
    }
    if (kategori != null && kategori.isNotEmpty) {
      where = (where == null) ? 'kategori = ?' : '$where AND kategori = ?';
      args = (args == null) ? [kategori] : [...args, kategori];
    }
    final rows = await _db.query(
      'products',
      where: where,
      whereArgs: args,
      orderBy: orderBy,
    );
    return rows
        .map((r) => ProductModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<int> addImage(ProductImageModel img) async {
    final now = DateTime.now().toIso8601String();
    final map = img.toMap();
    map['created_at'] = now;
    return await _db.insert('product_images', map);
  }

  Future<int> addProductImage({
    required int productId,
    required String imagePath,
  }) async {
    final img = ProductImageModel(productId: productId, imagePath: imagePath);
    return await addImage(img);
  }

  Future<List<ProductImageModel>> getImages(int productId) async {
    final rows = await _db.query(
      'product_images',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return rows
        .map((r) => ProductImageModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<int> deleteProduct(int id) async {
    // Also delete associated images
    await _db.delete('product_images', 'product_id = ?', [id]);
    return await _db.delete('products', 'id = ?', [id]);
  }

  Future<int> deleteProductImage(int id) async {
    return await _db.delete('product_images', 'id = ?', [id]);
  }

  Future<int> updateProduct(ProductModel p) async {
    final now = DateTime.now().toIso8601String();
    final map = p.toMap();
    map['updated_at'] = now;
    map.remove('created_at');
    return await _db.update('products', map, 'id = ?', [p.id!]);
  }

  Future<String> getSellerName(int userId) async {
    try {
      final rows = await _db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (rows.isNotEmpty) {
        return rows.first['nama'] as String? ?? 'Seller';
      }
    } catch (_) {}
    return 'Seller';
  }

  Future<String?> getSellerWhatsapp(int userId) async {
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
