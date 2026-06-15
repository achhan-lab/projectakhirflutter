import 'package:flutter/material.dart';
import '../../models/forum_post_model.dart';
import '../../services/forum_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/skeleton_loading.dart';
import 'create_post_screen.dart';
import 'forum_detail_screen.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ForumService _forumService = ForumService();
  final _searchCtrl = TextEditingController();
  List<ForumPostModel> _posts = [];
  List<ForumPostModel> _filteredPosts = [];
  final Map<int, String> _authorNames = {};
  bool _isLoading = true;
  String _selectedKategori = 'Semua';
  int? _currentUserId;

  final List<String> _kategoriList = [
    'Semua',
    'PKM',
    'Supplier',
    'Lowongan',
    'Diskusi',
    'Lainnya',
  ];

  final Map<String, Color> _kategoriColors = {
    'PKM': const Color(0xFF8B5CF6),
    'Supplier': const Color(0xFFF59E0B),
    'Lowongan': const Color(0xFF3B82F6),
    'Diskusi': const Color(0xFF27AE60),
    'Lainnya': const Color(0xFF6B7280),
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPosts();
  }

  void _loadCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (user != null && mounted) {
      setState(() => _currentUserId = user.id);
    }
  }

  void _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _forumService.getAllPosts(
        kategori: _selectedKategori == 'Semua' ? null : _selectedKategori,
      );

      final authorNames = <int, String>{};
      for (final p in posts) {
        if (!authorNames.containsKey(p.userId)) {
          authorNames[p.userId] = await _forumService.getAuthorName(p.userId);
        }
      }

      if (mounted) {
        setState(() {
          _posts = posts;
          _authorNames.addAll(authorNames);
          _isLoading = false;
        });
        _filterPosts();
      }
    } catch (e) {
      debugPrint('Error loading forum posts: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterPosts() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredPosts = _posts;
      } else {
        _filteredPosts = _posts.where((p) {
          return p.content.toLowerCase().contains(query) ||
              (_authorNames[p.userId]?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    if (result == true) _loadPosts();
  }

  void _navigateToDetail(ForumPostModel post) async {
    final authorName = _authorNames[post.userId] ?? 'Anonim';
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ForumDetailScreen(
          post: post,
          authorName: authorName,
          currentUserId: _currentUserId,
        ),
      ),
    );
    if (result == true) _loadPosts();
  }

  void _deletePost(ForumPostModel post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Postingan',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Yakin ingin menghapus postingan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Colors.grey[500])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _forumService.deletePost(post.id!);
                if (mounted) {
                  AppToast.success(context, 'Postingan berhasil dihapus');
                  _loadPosts();
                }
              } catch (e) {
                if (mounted) AppToast.error(context, 'Error: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return '${diff.inDays ~/ 7}mgg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forum',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Diskusi & kolaborasi mahasiswa',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToCreatePost,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.edit_square,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _filterPosts(),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari postingan...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.grey[400], size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category chips
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _kategoriList.length,
                itemBuilder: (context, index) {
                  final kat = _kategoriList[index];
                  final isSelected = _selectedKategori == kat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedKategori = kat);
                        _loadPosts();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF27AE60)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF27AE60)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          kat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Posts feed
            Expanded(
              child: _isLoading
                  ? const SkeletonLoading(itemCount: 4, isGrid: false)
                  : _filteredPosts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: const Color(0xFF27AE60),
                          onRefresh: () async => _loadPosts(),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredPosts.length,
                            itemBuilder: (context, index) =>
                                _buildPostCard(_filteredPosts[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(ForumPostModel post) {
    final authorName = _authorNames[post.userId] ?? 'Anonim';
    final initial =
        authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A';
    final katColor = _kategoriColors[post.kategori] ?? Colors.grey;
    final isOwner = _currentUserId != null && post.userId == _currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _navigateToDetail(post),
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF27AE60),
                          const Color(0xFF2ECC71).withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          _timeAgo(post.createdAt),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: katColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      post.kategori,
                      style: TextStyle(
                        fontSize: 11,
                        color: katColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Edit/Delete menu for owner
                  if (isOwner)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded,
                            size: 20, color: Colors.grey[400]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == 'delete') _deletePost(post);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 10),
                                Text('Hapus',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                post.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 40,
              color: Color(0xFF27AE60),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada postingan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Jadilah yang pertama posting di forum!',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _navigateToCreatePost,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Buat Postingan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
