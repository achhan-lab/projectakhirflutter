import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Kebijakan Privasi',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kebijakan Privasi SAMBA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Terakhir diperbarui: 1 Januari 2025',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 24),
              _Section(
                title: '1. Informasi yang Kami Kumpulkan',
                content:
                    'Kami mengumpulkan informasi yang Anda berikan secara langsung, termasuk nama, NIM, nomor WhatsApp, dan password saat Anda mendaftar akun. Kami juga mengumpulkan informasi produk yang Anda unggah termasuk nama produk, harga, deskripsi, dan foto.',
              ),
              SizedBox(height: 16),
              _Section(
                title: '2. Penggunaan Informasi',
                content:
                    'Informasi yang dikumpulkan digunakan untuk:\n• Menyediakan layanan marketplace kampus\n• Menampilkan produk Anda kepada pengguna lain\n• Menghubungkan penjual dan pembeli melalui WhatsApp\n• Meningkatkan kualitas layanan SAMBA',
              ),
              SizedBox(height: 16),
              _Section(
                title: '3. Penyimpanan Data',
                content:
                    'Data Anda disimpan secara lokal di perangkat Anda menggunakan database SQLite. Kami tidak mengirim data ke server eksternal. Data akan tetap tersimpan selama aplikasi terinstall di perangkat Anda.',
              ),
              SizedBox(height: 16),
              _Section(
                title: '4. Keamanan',
                content:
                    'Kami menyimpan password Anda di database lokal perangkat. Untuk keamanan tambahan, kami menyarankan Anda menggunakan password yang kuat dan tidak membagikan informasi akun kepada orang lain.',
              ),
              SizedBox(height: 16),
              _Section(
                title: '5. Kontak',
                content:
                    'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi tim pengembang SAMBA melalui forum di dalam aplikasi.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4A4A68),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
