import 'package:flutter/material.dart';
import '../../models/colab_model.dart';
import '../../services/colab_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_toast.dart';
import '../../core/utils/app_constants.dart';

class CreateColabScreen extends StatefulWidget {
  final ColabModel? editColab;

  const CreateColabScreen({super.key, this.editColab});

  @override
  State<CreateColabScreen> createState() => _CreateColabScreenState();
}

class _CreateColabScreenState extends State<CreateColabScreen> {
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _tujuanCtrl = TextEditingController();
  final _maxAnggotaCtrl = TextEditingController(text: '5');
  String _kategori = 'PKM';
  bool _isLoading = false;
  int? _currentUserId;
  bool get _isEditing => widget.editColab != null;

  @override
  void initState() {
    super.initState();
    _loadUser();
    if (_isEditing) {
      _judulCtrl.text = widget.editColab!.judul;
      _deskripsiCtrl.text = widget.editColab!.deskripsi;
      _tujuanCtrl.text = widget.editColab!.tujuan;
      _maxAnggotaCtrl.text = widget.editColab!.maxAnggota.toString();
      _kategori = widget.editColab!.kategori;
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
      return _judulCtrl.text.trim() != widget.editColab!.judul ||
          _deskripsiCtrl.text.trim() != widget.editColab!.deskripsi ||
          _tujuanCtrl.text.trim() != widget.editColab!.tujuan ||
          _kategori != widget.editColab!.kategori;
    }
    return _judulCtrl.text.trim().isNotEmpty ||
        _deskripsiCtrl.text.trim().isNotEmpty;
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
    final judul = _judulCtrl.text.trim();
    final deskripsi = _deskripsiCtrl.text.trim();
    final tujuan = _tujuanCtrl.text.trim();
    final maxAnggota = int.tryParse(_maxAnggotaCtrl.text) ?? 5;

    if (judul.isEmpty) {
      AppToast.error(context, 'Judul wajib diisi');
      return;
    }
    if (deskripsi.isEmpty) {
      AppToast.error(context, 'Deskripsi wajib diisi');
      return;
    }
    if (tujuan.isEmpty) {
      AppToast.error(context, 'Tujuan wajib diisi');
      return;
    }
    if (_currentUserId == null && !_isEditing) {
      AppToast.error(context, 'User tidak teridentifikasi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        final updated = ColabModel(
          id: widget.editColab!.id,
          userId: widget.editColab!.userId,
          judul: judul,
          deskripsi: deskripsi,
          kategori: _kategori,
          tujuan: tujuan,
          maxAnggota: maxAnggota,
          currentAnggota: widget.editColab!.currentAnggota,
          status: widget.editColab!.status,
          createdAt: widget.editColab!.createdAt,
        );
        await ColabService().updateColab(updated);
        if (!mounted) return;
        AppToast.success(context, 'Kolaborasi berhasil diperbarui!');
      } else {
        await ColabService().createColab(ColabModel(
          userId: _currentUserId!,
          judul: judul,
          deskripsi: deskripsi,
          kategori: _kategori,
          tujuan: tujuan,
          maxAnggota: maxAnggota,
        ));
        if (!mounted) return;
        AppToast.success(context, 'Kolaborasi berhasil dibuat!');
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Gagal menyimpan kolaborasi.');
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
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textDark,
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
              _isEditing ? 'Edit Kolaborasi' : 'Buat Kolaborasi',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: _isLoading ? null : _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category selection
                _sectionTitle('Tujuan Kolaborasi'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colabCategories
                      .where((k) => k != 'Semua')
                      .map((kat) {
                    final isSelected = _kategori == kat;
                    return GestureDetector(
                      onTap: () => setState(() => _kategori = kat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              colabIcons[kat] ?? Icons.circle_outlined,
                              size: 16,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              kat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Judul
                _sectionTitle('Judul'),
                const SizedBox(height: 8),
                _buildInput(
                  controller: _judulCtrl,
                  hint: 'Contoh: Tim PKM Kewirausahaan 2025',
                ),
                const SizedBox(height: 20),

                // Deskripsi
                _sectionTitle('Deskripsi'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _deskripsiCtrl,
                    maxLines: 5,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                    decoration: InputDecoration(
                      hintText:
                          'Jelaskan detail kolaborasi, skill yang dicari, dll...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tujuan
                _sectionTitle('Tujuan'),
                const SizedBox(height: 8),
                _buildInput(
                  controller: _tujuanCtrl,
                  hint: 'Contoh: Lolos PKM-K dan didanai DIKTI',
                ),
                const SizedBox(height: 20),

                // Max Anggota
                _sectionTitle('Maksimal Anggota'),
                const SizedBox(height: 8),
                _buildInput(
                  controller: _maxAnggotaCtrl,
                  hint: '5',
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
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
        color: AppColors.background,
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
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    _tujuanCtrl.dispose();
    _maxAnggotaCtrl.dispose();
    super.dispose();
  }
}
