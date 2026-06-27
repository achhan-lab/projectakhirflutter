import 'package:flutter/material.dart';
import '../../models/forum_post_model.dart';
import '../../services/forum_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_toast.dart';

class CreatePostScreen extends StatefulWidget {
  final ForumPostModel? editPost;

  const CreatePostScreen({super.key, this.editPost});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentCtrl = TextEditingController();
  String _kategori = 'Diskusi';
  bool _isLoading = false;
  int? _currentUserId;
  bool get _isEditing => widget.editPost != null;

  final List<String> _kategoriList = [
    'PKM',
    'Supplier',
    'Lowongan',
    'Diskusi',
    'Lainnya',
  ];

  final Map<String, IconData> _kategoriIcons = {
    'PKM': Icons.emoji_events_outlined,
    'Supplier': Icons.store_outlined,
    'Lowongan': Icons.work_outline,
    'Diskusi': Icons.chat_bubble_outline,
    'Lainnya': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _loadUser();
    if (_isEditing) {
      _contentCtrl.text = widget.editPost!.content;
      _kategori = widget.editPost!.kategori;
    }
  }

  void _loadUser() async {
    final user = await AuthService().getCurrentUser();
    if (user != null && mounted) {
      setState(() => _currentUserId = user.id);
    }
  }

  bool get _hasUnsavedChanges {
    if (_isEditing) {
      return _contentCtrl.text.trim() != widget.editPost!.content ||
          _kategori != widget.editPost!.kategori;
    }
    return _contentCtrl.text.trim().isNotEmpty;
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Buang Perubahan?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Perubahan yang sudah kamu buat tidak akan disimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey[500])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Buang'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _submit() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      AppToast.warning(context, 'Tulis sesuatu dulu!');
      return;
    }
    if (_currentUserId == null && !_isEditing) {
      AppToast.error(context, 'User tidak teridentifikasi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        final updated = ForumPostModel(
          id: widget.editPost!.id,
          userId: widget.editPost!.userId,
          content: content,
          kategori: _kategori,
          createdAt: widget.editPost!.createdAt,
        );
        await ForumService().updatePost(updated);
        if (!mounted) return;
        AppToast.success(context, 'Postingan berhasil diperbarui!');
      } else {
        await ForumService().createPost(ForumPostModel(
          userId: _currentUserId!,
          content: content,
          kategori: _kategori,
        ));
        if (!mounted) return;
        AppToast.success(context, 'Postingan berhasil dibuat!');
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Gagal menyimpan postingan.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1A2E),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () async {
              final shouldPop = await _confirmDiscard();
              if (shouldPop && mounted) Navigator.pop(context);
            },
          ),
          title: Text(
            _isEditing ? 'Edit Postingan' : 'Buat Postingan',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _isLoading ? null : _submit,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isEditing ? 'Simpan' : 'Posting',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category selection
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kategoriList.map((kat) {
                  final isSelected = _kategori == kat;
                  return GestureDetector(
                    onTap: () => setState(() => _kategori = kat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _kategoriIcons[kat] ?? Icons.circle_outlined,
                            size: 16,
                            color:
                                isSelected ? Colors.white : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            kat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Content input
              const Text(
                'Postingan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _contentCtrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                    decoration: InputDecoration(
                      hintText:
                          'Contoh: Cari mahasiswa TI untuk tim PKM bidang...\n\nAtau: Ada yang tau supplier baju murah?',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }
}
