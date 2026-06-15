import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/app_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _waCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPass = false;
  bool _isLoading = false;

  void _register() async {
    final name = _nameCtrl.text.trim();
    final nim = _nimCtrl.text.trim();
    final wa = _waCtrl.text.trim();
    final pass = _passCtrl.text;
    final conf = _confirmCtrl.text;

    // Auto-convert 08xxx to 628xxx
    final formattedWa = wa.startsWith('0') ? '62${wa.substring(1)}' : wa;

    if (name.isEmpty || nim.isEmpty || wa.isEmpty || pass.isEmpty) {
      AppToast.error(context, 'Semua field wajib diisi');
      return;
    }
    if (pass.length < 8) {
      AppToast.warning(context, 'Password minimal 8 karakter');
      return;
    }
    if (pass != conf) {
      AppToast.error(context, 'Konfirmasi password tidak sama');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().register(UserModel(
        nama: name,
        email: nim,
        password: pass,
        noWhatsapp: formattedWa,
      ));
      if (!mounted) return;
      AppToast.success(context, 'Registrasi berhasil! Silakan login 🎉');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/get-started', (_) => false),
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                'Daftar ✨',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Buat akun SAMBA baru',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 36),

              // Name
              _label('Nama Lengkap'),
              const SizedBox(height: 8),
              _input(
                controller: _nameCtrl,
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // NIM
              _label('NIM'),
              const SizedBox(height: 8),
              _input(
                controller: _nimCtrl,
                hint: 'Masukkan NIM',
                icon: Icons.badge_outlined,
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // WhatsApp
              _label('Nomor WhatsApp'),
              const SizedBox(height: 8),
              _input(
                controller: _waCtrl,
                hint: '08XXXXXXXXXX',
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Password
              _label('Password'),
              const SizedBox(height: 8),
              _input(
                controller: _passCtrl,
                hint: 'Minimal 8 karakter',
                icon: Icons.lock_outline,
                obscure: !_showPass,
                suffix: IconButton(
                  onPressed: () => setState(() => _showPass = !_showPass),
                  icon: Icon(
                    _showPass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _label('Konfirmasi Password'),
              const SizedBox(height: 8),
              _input(
                controller: _confirmCtrl,
                hint: 'Ulangi password',
                icon: Icons.lock_outline,
                obscure: true,
              ),
              const SizedBox(height: 32),

              // Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    disabledBackgroundColor:
                        const Color(0xFF27AE60).withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Login link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF27AE60),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nimCtrl.dispose();
    _waCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }
}
