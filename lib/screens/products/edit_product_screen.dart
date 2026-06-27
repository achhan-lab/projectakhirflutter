import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/product_model.dart';
import '../../models/product_image_model.dart';
import '../../services/product_service.dart';
import '../../widgets/app_toast.dart';
import '../../core/utils/app_constants.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _name;
  late TextEditingController _price;
  late TextEditingController _desc;
  late TextEditingController _stock;
  late String _kategori;
  final ProductService _svc = ProductService();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _newImages = [];
  List<ProductImageModel> _existingImages = [];
  bool _isLoading = false;

  static const int maxImages = 5;
  static const int maxSizeInBytes = 1048576;



  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.product.namaProduk);
    _price = TextEditingController(text: widget.product.harga.toString());
    _desc = TextEditingController(text: widget.product.deskripsi);
    _stock = TextEditingController(text: widget.product.stok.toString());
    _kategori = widget.product.kategori;
    _loadExistingImages();
  }

  void _loadExistingImages() async {
    if (widget.product.id != null) {
      final images = await _svc.getImages(widget.product.id!);
      if (mounted) setState(() => _existingImages = images);
    }
  }

  Future<void> _pickImage() async {
    if (_existingImages.length + _newImages.length >= maxImages) {
      if (!mounted) return;
      AppToast.warning(context, 'Maksimal $maxImages foto');
      return;
    }
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (image != null) {
        final size = await File(image.path).length();
        if (!mounted) return;
        if (size > maxSizeInBytes) {
          AppToast.error(context, 'Ukuran foto maksimal 1MB');
          return;
        }
        setState(() => _newImages.add(image));
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Error memilih foto: $e');
    }
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  void _removeExistingImage(ProductImageModel img) async {
    try {
      await _svc.deleteProductImage(img.id!);
      if (!mounted) return;
      setState(() => _existingImages.remove(img));
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Error menghapus foto: $e');
    }
  }

  void _save() async {
    final nama = _name.text.trim();
    final harga = int.tryParse(_price.text) ?? 0;
    final stok = int.tryParse(_stock.text) ?? 0;

    if (nama.isEmpty) {
      AppToast.error(context, 'Nama produk wajib diisi');
      return;
    }
    if (harga <= 0) {
      AppToast.error(context, 'Harga harus lebih dari 0');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final updated = ProductModel(
        id: widget.product.id,
        userId: widget.product.userId,
        namaProduk: nama,
        harga: harga,
        stok: stok,
        kategori: _kategori,
        deskripsi: _desc.text.trim(),
        createdAt: widget.product.createdAt,
        updatedAt: widget.product.updatedAt,
      );

      await _svc.updateProduct(updated);

      // Add new images
      for (final img in _newImages) {
        await _svc.addProductImage(
          productId: widget.product.id!,
          imagePath: img.path,
        );
      }

      if (!mounted) return;
      AppToast.success(context, 'Produk berhasil diperbarui!');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Gagal mengupdate produk.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Edit Produk',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos section
            _sectionTitle('Foto Produk'),
            const SizedBox(height: 4),
            Text(
              '${_existingImages.length + _newImages.length}/$maxImages foto',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            _buildImageGrid(),
            const SizedBox(height: 28),

            // Name
            _sectionTitle('Nama Produk'),
            const SizedBox(height: 8),
            _buildInput(controller: _name, hint: 'Nama produk'),
            const SizedBox(height: 20),

            // Price
            _sectionTitle('Harga'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _price,
              hint: 'Harga',
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Stock
            _sectionTitle('Stok'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _stock,
              hint: 'Jumlah stok',
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Category
            _sectionTitle('Kategori'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: DropdownButtonFormField<String>(
                value: _kategori,
                items: productCategories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _kategori = v ?? 'Lainnya'),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: Icon(Icons.category_outlined,
                      color: Colors.grey[400], size: 20),
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            _sectionTitle('Deskripsi'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _desc,
                maxLines: 4,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Deskripsi produk...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  disabledBackgroundColor:
                      const Color(0xFF27AE60).withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildImageGrid() {
    final totalImages = _existingImages.length + _newImages.length;
    final canAdd = totalImages < maxImages;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalImages + (canAdd ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _existingImages.length) {
            // Existing image
            final img = _existingImages[index];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImagePreview(img.imagePath),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => _removeExistingImage(img),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (index < totalImages) {
            // New image
            final newIndex = index - _existingImages.length;
            final img = _newImages[newIndex];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(img.path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => _removeNewImage(newIndex),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Add button
            return GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF27AE60).withValues(alpha: 0.04),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 28, color: Color(0xFF27AE60)),
                    SizedBox(height: 4),
                    Text(
                      'Tambah',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover,
          errorBuilder: (_, e, s) => _placeholder());
    }
    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    } catch (_) {}
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.broken_image, color: Colors.grey[400], size: 32),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _desc.dispose();
    _stock.dispose();
    super.dispose();
  }
}
