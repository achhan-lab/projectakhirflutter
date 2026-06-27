import 'package:flutter/material.dart';
import '../../models/colab_model.dart';
import '../../services/colab_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/skeleton_loading.dart';
import '../../widgets/category_chip.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/format_utils.dart';
import 'create_colab_screen.dart';
import 'colab_detail_screen.dart';

class ColabScreen extends StatefulWidget {
  const ColabScreen({super.key});

  @override
  State<ColabScreen> createState() => _ColabScreenState();
}

class _ColabScreenState extends State<ColabScreen> {
  final ColabService _colabService = ColabService();
  final _searchCtrl = TextEditingController();
  List<ColabModel> _colabs = [];
  List<ColabModel> _filteredColabs = [];
  final Map<int, String> _creatorNames = {};
  bool _isLoading = true;
  String _selectedKategori = 'Semua';
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadColabs();
  }

  void _loadCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (user != null && mounted) {
      setState(() => _currentUserId = user.id);
    }
  }

  void _loadColabs() async {
    setState(() => _isLoading = true);
    try {
      final colabs = await _colabService.getAllColabs(
        kategori: _selectedKategori == 'Semua' ? null : _selectedKategori,
      );

      final creatorNames = <int, String>{};
      for (final c in colabs) {
        if (!creatorNames.containsKey(c.userId)) {
          creatorNames[c.userId] = await _colabService.getCreatorName(c.userId);
        }
      }

      if (mounted) {
        setState(() {
          _colabs = colabs;
          _creatorNames.addAll(creatorNames);
          _isLoading = false;
        });
        _filterColabs();
      }
    } catch (e) {
      debugPrint('Error loading colabs: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterColabs() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredColabs = _colabs;
      } else {
        _filteredColabs = _colabs.where((c) {
          return c.judul.toLowerCase().contains(query) ||
              c.deskripsi.toLowerCase().contains(query) ||
              (_creatorNames[c.userId]?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _filterColabs();
  }

  void _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateColabScreen()),
    );
    if (result == true) _loadColabs();
  }

  void _navigateToDetail(ColabModel colab) async {
    final creatorName = _creatorNames[colab.userId] ?? 'Anonim';
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ColabDetailScreen(
          colab: colab,
          creatorName: creatorName,
          currentUserId: _currentUserId,
        ),
      ),
    );
    if (result == true) _loadColabs();
  }

  void _editColab(ColabModel colab) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateColabScreen(editColab: colab)),
    );
    if (result == true) _loadColabs();
  }

  void _deleteColab(ColabModel colab) {
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
                await _colabService.deleteColab(colab.id!);
                if (mounted) {
                  AppToast.success(context, 'Kolaborasi berhasil dihapus');
                  _loadColabs();
                }
              } catch (e) {
                if (mounted) AppToast.error(context, 'Gagal menghapus kolaborasi.');
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
    return Scaffold(
      backgroundColor: AppColors.background,
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
                          'Kolaborasi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cari tim & partner project',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _navigateToCreate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 22),
                      ),
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => _filterColabs(),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Cari kolaborasi...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: Colors.grey[400], size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      InkWell(
                        onTap: _clearSearch,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.close_rounded,
                              color: Colors.grey[400], size: 20),
                        ),
                      ),
                    const SizedBox(width: 8),
                  ],
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
                itemCount: colabCategories.length,
                itemBuilder: (context, index) {
                  final kat = colabCategories[index];
                  final isSelected = _selectedKategori == kat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: kat,
                      icon: colabIcons[kat],
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedKategori = kat);
                        _loadColabs();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Colab cards list
            Expanded(
              child: _isLoading
                  ? const SkeletonLoading(itemCount: 4, isGrid: false)
                  : _filteredColabs.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async => _loadColabs(),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredColabs.length,
                            itemBuilder: (context, index) =>
                                _buildColabCard(_filteredColabs[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColabCard(ColabModel colab) {
    final creatorName = _creatorNames[colab.userId] ?? 'Anonim';
    final initial =
        creatorName.isNotEmpty ? creatorName[0].toUpperCase() : 'A';
    final katColor = kategoriColors[colab.kategori] ?? Colors.grey;
    final statusColor = _getStatusColor(colab.status);
    final isOwner = _currentUserId != null && colab.userId == _currentUserId;
    final isFull = colab.currentAnggota >= colab.maxAnggota;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(colab),
          borderRadius: BorderRadius.circular(16),
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
                // Creator row
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
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
                            creatorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            FormatUtils.timeAgo(colab.createdAt, short: true),
                            style:
                                TextStyle(fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: katColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        colab.kategori,
                        style: TextStyle(
                          fontSize: 11,
                          color: katColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Menu for owner
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
                            if (value == 'edit') _editColab(colab);
                            if (value == 'delete') _deleteColab(colab);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined,
                                      size: 20, color: AppColors.blue),
                                  SizedBox(width: 10),
                                  Text('Edit',
                                      style: TextStyle(color: AppColors.blue)),
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

                // Title
                Text(
                  colab.judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  colab.deskripsi,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Bottom row: status + members + tujuan
                Row(
                  children: [
                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        colab.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Members
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isFull ? Colors.red : AppColors.blue)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 12,
                            color: isFull ? Colors.red : AppColors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${colab.currentAnggota}/${colab.maxAnggota}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isFull ? Colors.red : AppColors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Tujuan short
                    Expanded(
                      child: Text(
                        colab.tujuan,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada kolaborasi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Buat kolaborasi pertamamu!',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Buat Kolaborasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
    _searchCtrl.dispose();
    super.dispose();
  }
}
