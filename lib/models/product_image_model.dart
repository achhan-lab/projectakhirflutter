class ProductImageModel {
  final int? id;
  final int productId;
  final String imagePath;
  final String? createdAt;

  ProductImageModel({
    this.id,
    required this.productId,
    required this.imagePath,
    this.createdAt,
  });

  factory ProductImageModel.fromMap(Map<String, dynamic> m) =>
      ProductImageModel(
        id: m['id'] as int?,
        productId: m['product_id'] as int? ?? 0,
        imagePath: m['image_path'] as String? ?? '',
        createdAt: m['created_at'] as String?,
      );

  Map<String, Object?> toMap() => {
    'id': id,
    'product_id': productId,
    'image_path': imagePath,
    'created_at': createdAt,
  };
}
