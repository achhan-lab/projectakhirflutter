import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan',
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
                'Syarat & Ketentuan SAMBA',
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
                title: '1. Penerimaan Syarat',
                content:
                    'Dengan menggunakan aplikasi SAMBA, Anda menyetujui Syarat dan Ketentuan ini. SAMBA adalah platform marketplace yang ditujukan untuk mahasiswa dalam bertransaksi dan berkarya.',
              ),
              SizedBox(height: 16),
              _Section(
                title: '2. Akun Pengguna',
                content:
                    '• Anda harus mendaftar dengan NIM yang valid\n• Anda bertanggung jawab atas keamanan akun Anda\n• Satu orang hanya boleh memiliki satu akun\n• Informasi yang Anda berikan harus benar dan akurat',
              ),
              SizedBox(height: 16),
              _Section(
                title: '3. Jual Beli',
                content:
                    '• Penjual bertanggung jawab atas keakuratan deskripsi produk\n• Harga yang tercantum adalah harga final yang ditentukan penjual\n• Transaksi dilakukan secara langsung antara penjual dan pembeli melalui WhatsApp\n• SAMBA tidak bertanggung jawab atas kualitas produk atau jalannya transaksi',
              ),
              SizedBox(height: 16),
              _Section(
                title: '4. Konten yang Dilarang',
                content:
                    'Pengguna tidak diperbolehkan mengunggah:\n• Produk ilegal atau melanggar hukum\n• Konten yang mengandung SARA\n• Produk tiruan atau palsu\n• Konten yang melanggar hak cipta orang lain',
              ),
              SizedBox(height: 16),
              _Section(
                title: '5. Forum',
                content:
                    '• Postingan di forum harus relevan dengan kehidupan kampus\n• Dilarang melakukan spam atau promosi berlebihan\n• Dilarang menyebarkan informasi palsu\n• Hormati sesama pengguna forum',
              ),
              SizedBox(height: 16),
              _Section(
                title: '6. Perubahan Syarat',
                content:
                    'SAMBA berhak mengubah Syarat dan Ketentuan ini sewaktu-waktu. Perubahan akan diberitahukan melalui aplikasi. Penggunaan aplikasi setelah perubahan berarti Anda menyetujui syarat yang baru.',
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
