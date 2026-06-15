import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/product_image_model.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onBack;
  final Function(int)? onNavTap;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.onBack,
    this.onNavTap,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  List<ProductImageModel> _images = [];
  String _sellerName = 'Seller';
  String? _sellerWhatsapp;
  int _currentImageIndex = 0;
  int? _currentUserId;

  bool get _isOwnProduct =>
      _currentUserId != null && widget.product.userId == _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null && mounted) {
        setState(() => _currentUserId = user.id);
      }

      if (widget.product.id != null) {
        final images = await _productService.getImages(widget.product.id!);
        if (mounted) setState(() => _images = images);
      }
      _sellerName =
          await _productService.getSellerName(widget.product.userId);
      final wa =
          await _productService.getSellerWhatsapp(widget.product.userId);
      if (mounted) {
        setState(() => _sellerWhatsapp = wa);
      }
    } catch (e) {
      debugPrint('Error loading product details: $e');
    }
  }

  /// Convert 08xxx to 628xxx and strip non-digits
  String _formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) {
      return '62${cleaned.substring(1)}';
    }
    return cleaned;
  }

  void _contactSeller(BuildContext context) async {
    try {
      final rawPhone = _sellerWhatsapp ?? '';
      if (rawPhone.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nomor WhatsApp penjual tidak tersedia'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final phone = _formatPhone(rawPhone);
      final msg = Uri.encodeComponent(
        'Halo $_sellerName, saya tertarik dengan produk "${widget.product.namaProduk}" yang Anda jual di SAMBA.',
      );
      final url = Uri.parse('https://wa.me/$phone?text=$msg');
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Tidak dapat membuka WhatsApp. Pastikan aplikasi WhatsApp terinstall.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _openImageViewer(int startIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageViewer(
          images: _images,
          initialIndex: startIndex,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.arrow_back_ios_new, size: 16),
                ),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(
          widget.product.namaProduk,
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section - tappable to open viewer
            GestureDetector(
              onTap: _images.isNotEmpty ? () => _openImageViewer(_currentImageIndex) : null,
              child: Container(
                height: 280,
                width: double.infinity,
                color: Colors.white,
                child: _images.isEmpty
                    ? Container(
                        color: const Color(0xFFF5F7FA),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada foto produk',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          PageView.builder(
                            itemCount: _images.length,
                            onPageChanged: (i) =>
                                setState(() => _currentImageIndex = i),
                            itemBuilder: (context, index) {
                              final path = _images[index].imagePath;
                              if (path.startsWith('http')) {
                                return Image.network(path,
                                    fit: BoxFit.cover);
                              } else {
                                final file = File(path);
                                return file.existsSync()
                                    ? Image.file(file,
                                        fit: BoxFit.cover)
                                    : Center(
                                        child: Icon(
                                            Icons.broken_image,
                                            size: 64,
                                            color: Colors.grey[300]));
                              }
                            },
                          ),
                          // Tap hint
                          if (_images.isNotEmpty)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          // Dots
                          if (_images.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: List.generate(
                                  _images.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 200),
                                    margin: const EdgeInsets
                                        .symmetric(horizontal: 3),
                                    width: _currentImageIndex == index
                                        ? 24
                                        : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex ==
                                              index
                                          ? const Color(0xFF27AE60)
                                          : Colors.white
                                              .withValues(alpha: 0.7),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price + Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rp ${_formatPrice(widget.product.harga)}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xFF27AE60),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.product.kategori,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF27AE60),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.namaProduk,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seller card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF27AE60),
                                Color(0xFF2ECC71),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              _sellerName.isNotEmpty
                                  ? _sellerName[0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isOwnProduct ? 'Produk Anda' : 'Penjual',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _sellerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.deskripsi,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      // Fixed bottom button - only show for OTHER people's products
      bottomNavigationBar: _isOwnProduct
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _contactSeller(context),
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text(
                    'Hubungi Penjual',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Full-screen image viewer with swipe between images
class _ImageViewer extends StatefulWidget {
  final List<ProductImageModel> images;
  final int initialIndex;

  const _ImageViewer({required this.images, this.initialIndex = 0});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          final path = widget.images[index].imagePath;
          if (path.startsWith('http')) {
            return InteractiveViewer(
              child: Center(
                child: Image.network(path, fit: BoxFit.contain),
              ),
            );
          } else {
            final file = File(path);
            if (file.existsSync()) {
              return InteractiveViewer(
                child: Center(
                  child: Image.file(file, fit: BoxFit.contain),
                ),
              );
            }
            return const Center(
              child: Icon(Icons.broken_image,
                  size: 64, color: Colors.white38),
            );
          }
        },
      ),
    );
  }
}
