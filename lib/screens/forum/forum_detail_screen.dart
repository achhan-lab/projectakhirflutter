import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/forum_post_model.dart';
import '../../services/forum_service.dart';
import '../../widgets/app_toast.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/app_constants.dart';
import 'create_post_screen.dart';

class ForumDetailScreen extends StatefulWidget {
  final ForumPostModel post;
  final String authorName;
  final int? currentUserId;

  const ForumDetailScreen({
    super.key,
    required this.post,
    required this.authorName,
    this.currentUserId,
  });

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  final ForumService _forumService = ForumService();
  String? _authorWhatsapp;



  void _loadAuthorWhatsapp() async {
    final wa = await _forumService.getAuthorWhatsapp(widget.post.userId);
    if (mounted) setState(() => _authorWhatsapp = wa);
  }


  bool get _isOwner =>
      widget.currentUserId != null && widget.post.userId == widget.currentUserId;

  ForumPostModel? _currentPost;
  bool _hasLiked = false;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _loadAuthorWhatsapp();
  }

  void _contactViaWhatsApp() async {
    final rawPhone = _authorWhatsapp ?? '';
    if (rawPhone.isEmpty) {
      if (!mounted) return;
      AppToast.error(context, 'Nomor WhatsApp tidak tersedia');
      return;
    }
    final phone = FormatUtils.formatPhone(rawPhone);
    final msg = Uri.encodeComponent(
      'Halo ${widget.authorName}, saya tertarik dengan postingan kamu di forum SAMBA.',
    );
    final url = Uri.parse('https://wa.me/$phone?text=$msg');
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      AppToast.error(context, 'Tidak dapat membuka WhatsApp');
    }
  }

  void _toggleLike() async {
    if (_currentPost == null || _currentPost!.id == null) return;
    final newLikes = _hasLiked
        ? _currentPost!.likes - 1
        : _currentPost!.likes + 1;
    final updated = ForumPostModel(
      id: _currentPost!.id,
      userId: _currentPost!.userId,
      content: _currentPost!.content,
      kategori: _currentPost!.kategori,
      likes: newLikes,
      comments: _currentPost!.comments,
      createdAt: _currentPost!.createdAt,
    );
    await _forumService.updatePost(updated);
    if (mounted) {
      setState(() {
        _hasLiked = !_hasLiked;
        _currentPost = updated;
      });
    }
  }

  void _editPost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(editPost: widget.post),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _deletePost() {
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
                await _forumService.deletePost(widget.post.id!);
                if (mounted) {
                  AppToast.success(context, 'Postingan berhasil dihapus');
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) AppToast.error(context, 'Gagal menghapus postingan.');
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

  @override
  Widget build(BuildContext context) {
    final initial = widget.authorName.isNotEmpty
        ? widget.authorName[0].toUpperCase()
        : 'A';
    final post = _currentPost ?? widget.post;
    final katColor = kategoriColors[post.kategori] ?? Colors.grey;
    final displayPhone = _authorWhatsapp != null
        ? FormatUtils.formatPhone(_authorWhatsapp!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Detail Postingan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (_isOwner)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'delete') _deletePost();
                if (value == 'edit') _editPost();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 20, color: Color(0xFF3B82F6)),
                      SizedBox(width: 10),
                      Text('Edit',
                          style: TextStyle(color: Color(0xFF3B82F6))),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author card
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
              child: Column(
                children: [
                  Row(
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
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.authorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              FormatUtils.timeAgo(post.createdAt),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: katColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          post.kategori,
                          style: TextStyle(
                            fontSize: 12,
                            color: katColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Like button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Row(
                          children: [
                            Icon(
                              _hasLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _hasLiked ? Colors.red : Colors.grey[400],
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${post.likes}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _hasLiked
                                    ? Colors.red
                                    : Colors.grey[500],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // WhatsApp CTA at bottom
      bottomNavigationBar: displayPhone != null
          ? Container(
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
                  onPressed: _contactViaWhatsApp,
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text(
                    'Hubungi via WhatsApp',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
