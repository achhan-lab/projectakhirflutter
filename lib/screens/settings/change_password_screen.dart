import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/database/sqlite_service.dart';
import '../../widgets/app_toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showOld = false;
  bool _showNew = false;
  bool _isLoading = false;

  void _save() async {
    final oldPass = _oldPassCtrl.text;
    final newPass = _newPassCtrl.text;
    final conf = _confirmCtrl.text;

    if (oldPass.isEmpty || newPass.isEmpty || conf.isEmpty) {
      AppToast.error(context, 'Semua field wajib diisi');
      return;
    }
    if (newPass.length < 8) {
      AppToast.warning(context, 'Password baru minimal 8 karakter');
      return;
    }
    if (newPass != conf) {
      AppToast.error(context, 'Konfirmasi password tidak sama');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await AuthService().getCurrentUser();
      if (!mounted) return;
      if (user == null || user.id == null) {
        AppToast.error(context, 'User tidak ditemukan');
        return;
      }

      // Verify old password
      final hashedOldPass = AuthService.hashPassword(oldPass);
      if (user.password != hashedOldPass) {
        AppToast.error(context, 'Password lama salah');
        return;
      }

      // Update password (hash it)
      final db = SQLiteService();
      await db.update(
        'users',
        {'password': AuthService.hashPassword(newPass)},
        'id = ?',
        [user.id],
      );

      if (!mounted) return;
      AppToast.success(context, 'Password berhasil diubah!');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Gagal mengubah password. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Ubah Password',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Password Lama'),
            const SizedBox(height: 8),
            _input(
              controller: _oldPassCtrl,
              hint: 'Masukkan password lama',
              obscure: !_showOld,
              suffix: IconButton(
                onPressed: () => setState(() => _showOld = !_showOld),
                icon: Icon(
                  _showOld
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _label('Password Baru'),
            const SizedBox(height: 8),
            _input(
              controller: _newPassCtrl,
              hint: 'Minimal 8 karakter',
              obscure: !_showNew,
              suffix: IconButton(
                onPressed: () => setState(() => _showNew = !_showNew),
                icon: Icon(
                  _showNew
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _label('Konfirmasi Password Baru'),
            const SizedBox(height: 8),
            _input(
              controller: _confirmCtrl,
              hint: 'Ulangi password baru',
              obscure: true,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  disabledBackgroundColor:
                      const Color(0xFF27AE60).withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Ubah Password',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E)));
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF27AE60), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }
}
