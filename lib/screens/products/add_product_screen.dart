import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _stock = TextEditingController(text: '1');
  String _kategori = 'Barang Bekas';
  final ProductService _svc = ProductService();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  int? _currentUserId;
  bool _isLoading = false;

  static const int maxImages = 5;
  static const int maxSizeInBytes = 1048576; // 1MB

  final List<String> _categories = [
    'Jasa',
    'Makanan & Minuman',
    'Barang Bekas',
    'Elektronik',
    'Buku',
    'Fashion & Aksesoris',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (user != null && mounted) {
      setState(() => _currentUserId = user.id);
    }
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= maxImages) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maksimal $maxImages foto sudah terpilih')),
      );
      return;
    }
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (image != null) {
        final size = await File(image.path).length();
        if (size > maxSizeInBytes) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ukuran foto maksimal 1MB. File ini ${(size / 1048576).toStringAsFixed(2)}MB',
              ),
            ),
          );
          return;
        }
        setState(() => _selectedImages.add(image));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih foto: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _save() async {
    final nama = _name.text.trim();
    final harga = int.tryParse(_price.text) ?? 0;
    final stok = int.tryParse(_stock.text) ?? 1;
    final desc = _desc.text.trim();

    if (nama.isEmpty) {
      _showError('Nama produk wajib diisi');
      return;
    }
    if (harga <= 0) {
      _showError('Harga harus lebih dari 0');
      return;
    }
    if (_currentUserId == null) {
      _showError('User tidak teridentifikasi');
      return;
    }

    setState(() => _isLoading = true);

    final p = ProductModel(
      userId: _currentUserId!,
      namaProduk: nama,
      harga: harga,
      stok: stok,
      kategori: _kategori,
      deskripsi: desc,
    );

    try {
      final productId = await _svc.addProduct(p);

      if (_selectedImages.isNotEmpty) {
        for (var i = 0; i < _selectedImages.length; i++) {
          await _svc.addProductImage(
            productId: productId,
            imagePath: _selectedImages[i].path,
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil disimpan!'),
          backgroundColor: Color(0xFF27AE60),
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Tambah Produk',
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
            // Photo Upload Section
            _buildSectionTitle('Foto Produk'),
            const SizedBox(height: 4),
            Text(
              'Tambahkan hingga $maxImages foto (${_selectedImages.length}/$maxImages)',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            _buildImagePicker(),
            const SizedBox(height: 28),

            // Product Name
            _buildSectionTitle('Nama Produk'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _name,
              hint: 'Contoh: iPhone 15 Pro Max',
              icon: Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 20),

            // Price
            _buildSectionTitle('Harga'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _price,
              hint: 'Contoh: 1500000',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  'Rp',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stock
            _buildSectionTitle('Stok'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _stock,
              hint: 'Jumlah stok tersedia',
              icon: Icons.inventory_2_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Category
            _buildSectionTitle('Kategori'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _kategori,
                items: _categories
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
            _buildSectionTitle('Deskripsi'),
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
                  hintText: 'Jelaskan produk kamu secara detail...',
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
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Simpan Produk',
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
    );
  }

  Widget _buildSectionTitle(String title) {
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
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, color: Colors.grey[400], size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          prefix: prefix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length +
                  (_selectedImages.length < maxImages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _selectedImages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            image: DecorationImage(
                              image:
                                  FileImage(File(_selectedImages[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return _buildAddImageButton();
                }
              },
            ),
          )
        else
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF27AE60).withValues(alpha: 0.04),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 24,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap untuk tambah foto',
                    style: TextStyle(
                      color: Color(0xFF27AE60),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_selectedImages.isNotEmpty && _selectedImages.length < maxImages)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18, color: Color(0xFF27AE60)),
                    SizedBox(width: 4),
                    Text(
                      'Tambah Foto',
                      style: TextStyle(
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            borderRadius: BorderRadius.circular(14),
            color: Colors.grey[50],
          ),
          child: Icon(Icons.add, color: Colors.grey[400], size: 28),
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
