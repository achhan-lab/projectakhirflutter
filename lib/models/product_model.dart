class ProductModel {
  final int? id;
  final int userId;
  final String namaProduk;
  final int harga;
  final int stok;
  final String kategori;
  final String deskripsi;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    this.id,
    required this.userId,
    required this.namaProduk,
    required this.harga,
    this.stok = 0,
    required this.kategori,
    required this.deskripsi,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> m) => ProductModel(
    id: m['id'] as int?,
    userId: m['user_id'] as int? ?? 0,
    namaProduk: m['nama_produk'] as String? ?? '',
    harga: m['harga'] as int? ?? 0,
    stok: m['stok'] as int? ?? 0,
    kategori: m['kategori'] as String? ?? '',
    deskripsi: m['deskripsi'] as String? ?? '',
    createdAt: m['created_at'] as String?,
    updatedAt: m['updated_at'] as String?,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': userId,
    'nama_produk': namaProduk,
    'harga': harga,
    'stok': stok,
    'kategori': kategori,
    'deskripsi': deskripsi,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
