import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/forum_post_model.dart';
import '../../services/forum_service.dart';
import '../../widgets/app_toast.dart';

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
    _loadAuthorWhatsapp();
  }

  void _loadAuthorWhatsapp() async {
    final wa = await _forumService.getAuthorWhatsapp(widget.post.userId);
    if (mounted) setState(() => _authorWhatsapp = wa);
  }

  /// Convert 08xxx to 628xxx format
  String _formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) {
      return '62${cleaned.substring(1)}';
    }
    return cleaned;
  }

  bool get _isOwner =>
      widget.currentUserId != null && widget.post.userId == widget.currentUserId;

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${diff.inDays ~/ 7} minggu lalu';
  }

  void _contactViaWhatsApp() async {
    final rawPhone = _authorWhatsapp ?? '';
    if (rawPhone.isEmpty) {
      if (!mounted) return;
      AppToast.error(context, 'Nomor WhatsApp tidak tersedia');
      return;
    }
    final phone = _formatPhone(rawPhone);
    final msg = Uri.encodeComponent(
      'Halo ${widget.authorName}, saya tertarik dengan postingan kamu di forum SAMBA.',
    );
    final url = Uri.parse('https://wa.me/$phone?text=$msg');
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      AppToast.error(context, 'Tidak dapat membuka WhatsApp');
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

  @override
  Widget build(BuildContext context) {
    final initial = widget.authorName.isNotEmpty
        ? widget.authorName[0].toUpperCase()
        : 'A';
    final katColor = _kategoriColors[widget.post.kategori] ?? Colors.grey;
    final displayPhone = _authorWhatsapp != null
        ? _formatPhone(_authorWhatsapp!)
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
              },
              itemBuilder: (context) => [
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
                              _timeAgo(widget.post.createdAt),
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
                          widget.post.kategori,
                          style: TextStyle(
                            fontSize: 12,
                            color: katColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // WhatsApp number row
                  if (displayPhone != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF25D366).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 18, color: Color(0xFF25D366)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '+$displayPhone',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
              child: Text(
                widget.post.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                  height: 1.7,
                ),
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
