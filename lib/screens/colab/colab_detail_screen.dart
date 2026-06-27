import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/colab_model.dart';
import '../../services/colab_service.dart';
import '../../widgets/app_toast.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/format_utils.dart';
import 'create_colab_screen.dart';

class ColabDetailScreen extends StatefulWidget {
  final ColabModel colab;
  final String creatorName;
  final int? currentUserId;

  const ColabDetailScreen({
    super.key,
    required this.colab,
    required this.creatorName,
    this.currentUserId,
  });

  @override
  State<ColabDetailScreen> createState() => _ColabDetailScreenState();
}

class _ColabDetailScreenState extends State<ColabDetailScreen> {
  final ColabService _colabService = ColabService();
  String? _creatorWhatsapp;
  ColabModel? _colab;

  bool get _isOwner =>
      widget.currentUserId != null && widget.colab.userId == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _colab = widget.colab;
    _loadCreatorWhatsapp();
  }

  void _loadCreatorWhatsapp() async {
    final wa = await _colabService.getCreatorWhatsapp(widget.colab.userId);
    if (mounted) setState(() => _creatorWhatsapp = wa);
  }

  void _contactViaWhatsApp() async {
    final rawPhone = _creatorWhatsapp ?? '';
    if (rawPhone.isEmpty) {
      if (!mounted) return;
      AppToast.error(context, 'Nomor WhatsApp tidak tersedia');
      return;
    }
    final phone = FormatUtils.formatPhone(rawPhone);
    final msg = Uri.encodeComponent(
      'Halo ${widget.creatorName}, saya tertarik dengan kolaborasi "${widget.colab.judul}" di SAMBA.',
    );
    final url = Uri.parse('https://wa.me/$phone?text=$msg');
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      AppToast.error(context, 'Tidak dapat membuka WhatsApp');
    }
  }

  void _joinColab() async {
    if (_colab == null || _colab!.id == null) return;
    try {
      final result = await _colabService.joinColab(_colab!.id!);
      if (!mounted) return;
      if (result == -1) {
        AppToast.warning(context, 'Tim sudah penuh!');
      } else {
        AppToast.success(context, 'Berhasil bergabung ke tim!');
        // Reload colab data
        final updated = await _colabService.getColab(_colab!.id!);
        if (updated != null && mounted) {
          setState(() => _colab = updated);
        }
      }
    } catch (e) {
      if (mounted) AppToast.error(context, 'Gagal bergabung ke tim.');
    }
  }

  void _editColab() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateColabScreen(editColab: _colab ?? widget.colab),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _deleteColab() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kolaborasi',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Yakin ingin menghapus kolaborasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Colors.grey[500])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _colabService.deleteColab(widget.colab.id!);
                if (mounted) {
                  AppToast.success(context, 'Kolaborasi berhasil dihapus');
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) AppToast.error(context, 'Gagal menghapus.');
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.primary;
      case 'In Progress':
        return AppColors.blue;
      case 'Completed':
        return AppColors.grey;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colab = _colab ?? widget.colab;
    final initial = widget.creatorName.isNotEmpty
        ? widget.creatorName[0].toUpperCase()
        : 'A';
    final katColor = kategoriColors[colab.kategori] ?? Colors.grey;
    final statusColor = _getStatusColor(colab.status);
    final isFull = colab.currentAnggota >= colab.maxAnggota;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Kolaborasi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
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
                if (value == 'delete') _deleteColab();
                if (value == 'edit') _editColab();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 20, color: AppColors.blue),
                      SizedBox(width: 10),
                      Text('Edit', style: TextStyle(color: AppColors.blue)),
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
            // Creator card
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
                        colors: [AppColors.primary, AppColors.primaryLight],
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
                          widget.creatorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          FormatUtils.timeAgo(colab.createdAt),
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
                      colab.kategori,
                      style: TextStyle(
                        fontSize: 12,
                        color: katColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title + Status + Members
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
                  // Title
                  Text(
                    colab.judul,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status + Members row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          colab.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isFull ? Colors.red : AppColors.blue)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 14,
                              color: isFull ? Colors.red : AppColors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${colab.currentAnggota}/${colab.maxAnggota} anggota',
                              style: TextStyle(
                                fontSize: 12,
                                color: isFull ? Colors.red : AppColors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Member progress bar
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: colab.currentAnggota / colab.maxAnggota,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFull ? Colors.red : AppColors.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tujuan card
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
                  Row(
                    children: [
                      Icon(Icons.flag_outlined,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Tujuan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    colab.tujuan,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi card
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
                  Row(
                    children: [
                      Icon(Icons.description_outlined,
                          color: AppColors.blue, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    colab.deskripsi,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      // Bottom action bar
      bottomNavigationBar: _isOwner
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
              child: Row(
                children: [
                  // WhatsApp button
                  if (_creatorWhatsapp != null)
                    SizedBox(
                      height: 54,
                      width: 54,
                      child: OutlinedButton(
                        onPressed: _contactViaWhatsApp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.whatsapp,
                          side: const BorderSide(
                              color: AppColors.whatsapp, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.chat_bubble_outline, size: 22),
                      ),
                    ),
                  if (_creatorWhatsapp != null) const SizedBox(width: 12),
                  // Join button
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: (isFull || colab.status != 'Open')
                            ? null
                            : _joinColab,
                        icon: Icon(
                          isFull
                              ? Icons.group_off_rounded
                              : Icons.person_add_outlined,
                          size: 20,
                        ),
                        label: Text(
                          isFull
                              ? 'Tim Penuh'
                              : colab.status != 'Open'
                                  ? 'Tidak Tersedia'
                                  : 'Gabung Tim',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
