import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/sqlite_service.dart';
import 'auth_service.dart';

class SeedService {
  final SQLiteService _db = SQLiteService();

  Future<bool> isSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('data_seeded') ?? false;
  }

  Future<void> seed() async {
    if (await isSeeded()) return;

    debugPrint('🌱 Seeding dummy data...');
    try {
      await _seedUsers();
      await _seedProducts();
      await _seedForumPosts();
      await _seedColabs();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('data_seeded', true);
      debugPrint('✅ Seed data inserted successfully');
    } catch (e) {
      debugPrint('❌ Error seeding data: $e');
    }
  }

  Future<void> _seedUsers() async {
    final now = DateTime.now().toIso8601String();
    final users = [
      {
        'nama': 'Andi Pratama',
        'email': '17001001',
        'password': AuthService.hashPassword('password123'),
        'no_whatsapp': '6281234567890',
        'role': 'user',
        'created_at': now,
      },
      {
        'nama': 'Siti Rahayu',
        'email': '17001002',
        'password': AuthService.hashPassword('password123'),
        'no_whatsapp': '6281234567891',
        'role': 'user',
        'created_at': now,
      },
      {
        'nama': 'Budi Santoso',
        'email': '17001003',
        'password': AuthService.hashPassword('password123'),
        'no_whatsapp': '6281234567892',
        'role': 'user',
        'created_at': now,
      },
      {
        'nama': 'Dewi Lestari',
        'email': '17001004',
        'password': AuthService.hashPassword('password123'),
        'no_whatsapp': '6281234567893',
        'role': 'user',
        'created_at': now,
      },
      {
        'nama': 'Rizky Firmansyah',
        'email': '17001005',
        'password': AuthService.hashPassword('password123'),
        'no_whatsapp': '6281234567894',
        'role': 'user',
        'created_at': now,
      },
    ];

    for (final user in users) {
      await _db.insert('users', user);
    }
  }

  Future<void> _seedProducts() async {
    final now = DateTime.now().toIso8601String();
    final products = [
      {
        'user_id': 1,
        'nama_produk': 'iPhone 13 Pro 128GB',
        'harga': 12500000,
        'stok': 1,
        'kategori': 'Barang Bekas',
        'deskripsi':
            'iPhone 13 Pro kondisi mulus, battery health 92%. Lengkap dengan box dan charger.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 1,
        'nama_produk': 'Keyboard Mechanical Keychron K2',
        'harga': 850000,
        'stok': 2,
        'kategori': 'Barang Bekas',
        'deskripsi':
            'Keyboard mechanical wireless, switch Gateron Brown. Baru dipakai 3 bulan.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 2,
        'nama_produk': 'Jasa Desain Logo & Branding',
        'harga': 150000,
        'stok': 99,
        'kategori': 'Jasa',
        'deskripsi':
            'Jasa desain logo profesional untuk UMKM dan organisasi kampus. Revisi 3x.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 2,
        'nama_produk': 'Jasa Foto Produk',
        'harga': 200000,
        'stok': 99,
        'kategori': 'Jasa',
        'deskripsi':
            'Foto produk aesthetic untuk olshop. Sudah termasuk editing. Minimal 10 foto.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 3,
        'nama_produk': 'Lukisan Kanvas Abstract 60x80',
        'harga': 450000,
        'stok': 3,
        'kategori': 'Fashion & Aksesoris',
        'deskripsi':
            'Lukisan abstract acrylic on canvas. Cocok untuk dekorasi kamar atau cafe.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 3,
        'nama_produk': 'MacBook Air M1 256GB',
        'harga': 11000000,
        'stok': 1,
        'kategori': 'Barang Bekas',
        'deskripsi':
            'MacBook Air M1 kondisi 95%. Cycle count 120. Include charger original.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 4,
        'nama_produk': 'Buku Algoritma & Pemrograman',
        'harga': 75000,
        'stok': 5,
        'kategori': 'Buku',
        'deskripsi':
            'Buku kuliah semester 1. Kondisi bagus, ada highlight di beberapa bab.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 4,
        'nama_produk': 'Jasa Ketik & Print Dokumen',
        'harga': 5000,
        'stok': 99,
        'kategori': 'Jasa',
        'deskripsi':
            'Jasa ketik, print, dan jilid. Harga per halaman. Antar jemput area kampus.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 4,
        'nama_produk': 'Snack Box Paket Hemat',
        'harga': 25000,
        'stok': 20,
        'kategori': 'Makanan & Minuman',
        'deskripsi':
            'Paket snack box isi 5 macam. Cocok untuk rapat atau acara kampus.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 5,
        'nama_produk': 'Jasa Coding Website Landing Page',
        'harga': 500000,
        'stok': 99,
        'kategori': 'Jasa',
        'deskripsi':
            'Jasa bikin website landing page responsive. HTML/CSS/JS atau React. Pengerjaan 3-5 hari.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 5,
        'nama_produk': 'Kerajinan Resin Art Custom',
        'harga': 120000,
        'stok': 10,
        'kategori': 'Fashion & Aksesoris',
        'deskripsi':
            'Resin art custom: keychain, coaster, bookmark. Bisa request desain.',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 5,
        'nama_produk': 'PS5 Digital Edition + 2 Controller',
        'harga': 6500000,
        'stok': 1,
        'kategori': 'Barang Bekas',
        'deskripsi':
            'PS5 Digital Edition masih mulus. Include 2 DualSense controller dan 3 game digital.',
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final product in products) {
      await _db.insert('products', product);
    }
  }

  Future<void> _seedForumPosts() async {
    final now = DateTime.now().toIso8601String();
    final posts = [
      {
        'user_id': 1,
        'content':
            'Ada yang mau join tim PKM bidang Kewirausahaan? Butuh 2 orang lagi dari jurusan TI. Tema kita tentang platform marketplace kampus. Yang minat DM ya!',
        'kategori': 'PKM',
        'likes': 12,
        'comments': 5,
        'created_at': now,
      },
      {
        'user_id': 2,
        'content':
            'Cari supplier kaos polos bahan cotton combed 30s yang bisa satuan. Ada rekomendasi? Budget max 50rb per kaos. Untuk brand clothing kecil-kecilan.',
        'kategori': 'Supplier',
        'likes': 8,
        'comments': 3,
        'created_at': now,
      },
      {
        'user_id': 3,
        'content':
            'Info buat yang lagi cari kerja part-time: cafe dekat kampus lagi butuh barista. Shift fleksibel, bisa disesuaikan jadwal kuliah. Gaji 20rb/jam.',
        'kategori': 'Lowongan',
        'likes': 24,
        'comments': 11,
        'created_at': now,
      },
      {
        'user_id': 4,
        'content':
            'Menurut kalian, lebih enak jual produk pre-loved di SAMBA atau di marketplace biasa? Soalnya kalo di SAMBA kan satu kampus jadi lebih gampang COD.',
        'kategori': 'Diskusi',
        'likes': 15,
        'comments': 7,
        'created_at': now,
      },
      {
        'user_id': 5,
        'content':
            'Tim PKM-Karsa Cipta butuh anggota yang bisa Flutter/Dart. Kita bikin aplikasi mobile buat tracking skripsi. Yang berminat hubungi aku ya!',
        'kategori': 'PKM',
        'likes': 18,
        'comments': 9,
        'created_at': now,
      },
      {
        'user_id': 1,
        'content':
            'Jual murah buku-buku teknik informatika semester 1-4. Ada 15 buku, bisa beli satuan atau bundle. Bundle lebih murah!',
        'kategori': 'Diskusi',
        'likes': 6,
        'comments': 2,
        'created_at': now,
      },
      {
        'user_id': 3,
        'content':
            'Butuh supplier bahan baku resin untuk kerajinan. Yang tau toko online atau offline yang murah dan lengkap, boleh share ya. Thanks!',
        'kategori': 'Supplier',
        'likes': 10,
        'comments': 4,
        'created_at': now,
      },
    ];

    for (final post in posts) {
      await _db.insert('forum_posts', post);
    }
  }

  Future<void> _seedColabs() async {
    final now = DateTime.now().toIso8601String();
    final colabs = [
      {
        'user_id': 1,
        'judul': 'Tim PKM Kewirausahaan - Platform Marketplace Kampus',
        'deskripsi':
            'Mencari 2 anggota tim untuk PKM bidang Kewirausahaan. Ide: platform marketplace khusus kampus yang menghubungkan mahasiswa penjual dan pembeli. Fokus pada fitur COD area kampus.',
        'kategori': 'PKM',
        'tujuan': 'Lolos PKM-K dan didanai DIKTI',
        'max_anggota': 5,
        'current_anggota': 3,
        'status': 'Open',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 5,
        'judul': 'Tim PKM Karsa Cipta - Aplikasi Tracking Skripsi',
        'deskripsi':
            'Butuh anggota yang bisa Flutter/Dart untuk bikin aplikasi mobile tracking progress skripsi. Fitur: timeline, reminder bimbingan, catatan revisi.',
        'kategori': 'PKM',
        'tujuan': 'Ikut PKM-KC 2025',
        'max_anggota': 5,
        'current_anggota': 2,
        'status': 'Open',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 2,
        'judul': 'Project UI/UX Design - Aplikasi Booking Ruang Kelas',
        'deskripsi':
            'Kolaborasi desain UI/UX untuk aplikasi booking ruang kelas kampus. Butuh: 1 UI designer, 1 UX researcher, 1 frontend developer.',
        'kategori': 'Project',
        'tujuan': 'Portfolio dan submission ke kompetisi desain',
        'max_anggota': 4,
        'current_anggota': 1,
        'status': 'Open',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 3,
        'judul': 'Riset: Analisis Sentimen Mahasiswa terhadap Layanan Kampus',
        'deskripsi':
            'Mencari partner riset tentang analisis sentimen menggunakan NLP. Data dari survei mahasiswa. Target publikasi jurnal nasional.',
        'kategori': 'Riset',
        'tujuan': 'Publikasi jurnal nasional terakreditasi SINTA',
        'max_anggota': 3,
        'current_anggota': 1,
        'status': 'Open',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 4,
        'judul': 'Komunitas Belajar Bahasa Korea',
        'deskripsi':
            'Bikin komunitas belajar bahasa Korea bareng. Meeting 2x seminggu di perpustakaan. Level beginner-friendly. Gratis!',
        'kategori': 'Komunitas',
        'tujuan': 'Belajar bareng dan persiapan TOPIK',
        'max_anggota': 15,
        'current_anggota': 6,
        'status': 'Open',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 1,
        'judul': 'Project Mobile App - Sistem Informasi Kos',
        'deskripsi':
            'Kerjaan freelance bikin aplikasi mobile untuk manajemen kos. Fitur: pembayaran, komplain, maintenance request. Budget 3-5 juta.',
        'kategori': 'Project',
        'tujuan': 'Freelance project untuk pemilik kos',
        'max_anggota': 3,
        'current_anggota': 2,
        'status': 'In Progress',
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': 5,
        'judul': 'Tim Lomba Hackathon Nasional 2025',
        'deskripsi':
            'Cari 3 orang untuk tim hackathon: 1 backend (Node.js/Go), 1 ML engineer, 1 pitch presenter. Tema: Smart Campus.',
        'kategori': 'PKM',
        'tujuan': 'Juara hackathon nasional',
        'max_anggota': 4,
        'current_anggota': 1,
        'status': 'Open',
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final colab in colabs) {
      await _db.insert('colabs', colab);
    }
  }
}
