class UserModel {
  final int? id;
  final String nama;
  final String email;
  final String password;
  final String noWhatsapp;
  final String? fotoProfil;
  final String role;
  final String? createdAt;

  UserModel({
    this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.noWhatsapp,
    this.fotoProfil,
    this.role = 'user',
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'] as int?,
    nama: m['nama'] as String? ?? '',
    email: m['email'] as String? ?? '',
    password: m['password'] as String? ?? '',
    noWhatsapp: m['no_whatsapp'] as String? ?? '',
    fotoProfil: m['foto_profil'] as String?,
    role: m['role'] as String? ?? 'user',
    createdAt: m['created_at'] as String?,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'nama': nama,
    'email': email,
    'password': password,
    'no_whatsapp': noWhatsapp,
    'foto_profil': fotoProfil,
    'role': role,
    'created_at': createdAt,
  };
}
