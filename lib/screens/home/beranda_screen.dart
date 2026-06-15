import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton_loading.dart';
import '../products/product_detail_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedKategori = '';
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  final Map<int, String> _sellerNames = {};
  final Map<int, String?> _productImages = {};
  String _userName = '';
  bool _isLoading = true;

  final ProductService _productService = ProductService();

  final List<Map<String, dynamic>> _categoryItems = [
    {
      'label': 'Semua',
      'icon': Icons.apps_rounded,
      'color': const Color(0xFF27AE60),
    },
    {
      'label': 'Jasa',
      'icon': Icons.design_services_rounded,
      'color': const Color(0xFF60A5FA),
    },
    {
      'label': 'Makanan & Minuman',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFFBBF24),
    },
    {
      'label': 'Barang Bekas',
      'icon': Icons.shopping_bag_rounded,
      'color': const Color(0xFF4ADE80),
    },
    {
      'label': 'Elektronik',
      'icon': Icons.devices_rounded,
      'color': const Color(0xFF818CF8),
    },
    {
      'label': 'Buku',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFFB7185),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null && mounted) {
        setState(() => _userName = user.nama);
      }

      final dbProducts = await _productService.getAllProducts(
        orderBy: 'created_at DESC',
      );

      final sellerNames = <int, String>{};
      final productImages = <int, String?>{};

      for (final p in dbProducts) {
        if (!sellerNames.containsKey(p.userId)) {
          sellerNames[p.userId] =
              await _productService.getSellerName(p.userId);
        }
        if (p.id != null && !productImages.containsKey(p.id)) {
          final images = await _productService.getImages(p.id!);
          productImages[p.id!] =
              images.isNotEmpty ? images.first.imagePath : null;
        }
      }

      if (mounted) {
        setState(() {
          _products = dbProducts;
          _filteredProducts = dbProducts;
          _sellerNames.addAll(sellerNames);
          _productImages.addAll(productImages);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((p) {
        final matchSearch = p.namaProduk.toLowerCase().contains(query) ||
            p.deskripsi.toLowerCase().contains(query);
        final matchKategori = _selectedKategori.isEmpty ||
            _selectedKategori == 'Semua' ||
            p.kategori.toLowerCase().contains(_selectedKategori.toLowerCase());
        return matchSearch && matchKategori;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${_userName.isNotEmpty ? _userName.split(' ').take(2).join(' ') : 'Sobat'}! 👋',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Cari produk menarik di sini',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/images/samba.png',
                        width: 44,
                        height: 44,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => _filterProducts(),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari produk, jasa, atau karya...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Colors.grey[400], size: 22),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category chips
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categoryItems.length,
                      itemBuilder: (context, index) {
                        final item = _categoryItems[index];
                        final isSelected = _selectedKategori == item['label'] ||
                            (_selectedKategori.isEmpty &&
                                item['label'] == 'Semua');
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedKategori = isSelected
                                    ? ''
                                    : item['label'] as String;
                                _filterProducts();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF27AE60)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF27AE60)
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item['icon'] as IconData,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : item['color'] as Color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['label'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF4A4A68),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Product Grid
            Expanded(
              child: _isLoading
                  ? const SkeletonLoading(itemCount: 6, isGrid: true)
                  : _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: const Color(0xFF27AE60),
                          onRefresh: () async => _loadData(),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: GridView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredProducts.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.68,
                              ),
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                final imagePath = product.id != null
                                    ? _productImages[product.id!]
                                    : null;
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(
                                    milliseconds: 300 + (index * 80),
                                  ),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) =>
                                      Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  ),
                                  child: ProductCard(
                                    product: product,
                                    imagePath: imagePath,
                                    sellerName:
                                        _sellerNames[product.userId] ??
                                            'Seller',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProductDetailScreen(
                                                  product: product),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: Color(0xFF27AE60),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jadilah yang pertama menjual produk!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
