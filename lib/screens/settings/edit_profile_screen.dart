import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../core/database/sqlite_service.dart';
import '../../widgets/app_toast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _waCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  UserModel? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await AuthService().getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _user = user;
        _nameCtrl.text = user.nama;
        _waCtrl.text = user.noWhatsapp;
        _nimCtrl.text = user.email;
      });
    }
  }

  void _save() async {
    if (_user == null || _user!.id == null) return;
    final name = _nameCtrl.text.trim();
    final wa = _waCtrl.text.trim();

    if (name.isEmpty) {
      AppToast.error(context, 'Nama wajib diisi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Format phone number
      final formattedWa = wa.startsWith('0') ? '62${wa.substring(1)}' : wa;

      final db = SQLiteService();
      await db.update(
        'users',
        {'nama': name, 'no_whatsapp': formattedWa},
        'id = ?',
        [_user!.id],
      );

      if (!mounted) return;
      AppToast.success(context, 'Profil berhasil diperbarui!');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Edit Profil',
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
            // Avatar
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                  ),
                ),
                child: Center(
                  child: Text(
                    _nameCtrl.text.isNotEmpty
                        ? _nameCtrl.text[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // NIM (read-only)
            _label('NIM'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _nimCtrl.text,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            _label('Nama Lengkap'),
            const SizedBox(height: 8),
            _input(controller: _nameCtrl, hint: 'Nama lengkap'),
            const SizedBox(height: 20),

            // WhatsApp
            _label('Nomor WhatsApp'),
            const SizedBox(height: 8),
            _input(
                controller: _waCtrl,
                hint: '08XXXXXXXXXX',
                keyboard: TextInputType.phone),
            const SizedBox(height: 32),

            // Save
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
                    : const Text('Simpan Perubahan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
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

  Widget _input(
      {required TextEditingController controller,
      required String hint,
      TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
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
    _nameCtrl.dispose();
    _waCtrl.dispose();
    _nimCtrl.dispose();
    super.dispose();
  }
}
