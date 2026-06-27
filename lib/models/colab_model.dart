class ColabModel {
  final int? id;
  final int userId;
  final String judul;
  final String deskripsi;
  final String kategori; // PKM, Project, Riset, Komunitas, Lainnya
  final String tujuan;
  final int maxAnggota;
  final int currentAnggota;
  final String status; // Open, In Progress, Completed
  final String? createdAt;
  final String? updatedAt;

  ColabModel({
    this.id,
    required this.userId,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    required this.tujuan,
    this.maxAnggota = 5,
    this.currentAnggota = 1,
    this.status = 'Open',
    this.createdAt,
    this.updatedAt,
  });

  factory ColabModel.fromMap(Map<String, dynamic> m) => ColabModel(
        id: m['id'] as int?,
        userId: m['user_id'] as int? ?? 0,
        judul: m['judul'] as String? ?? '',
        deskripsi: m['deskripsi'] as String? ?? '',
        kategori: m['kategori'] as String? ?? 'Project',
        tujuan: m['tujuan'] as String? ?? '',
        maxAnggota: m['max_anggota'] as int? ?? 5,
        currentAnggota: m['current_anggota'] as int? ?? 1,
        status: m['status'] as String? ?? 'Open',
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'judul': judul,
        'deskripsi': deskripsi,
        'kategori': kategori,
        'tujuan': tujuan,
        'max_anggota': maxAnggota,
        'current_anggota': currentAnggota,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
