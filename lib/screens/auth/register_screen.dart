import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

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
  bool _showConfirmPass = false;
  bool _isLoading = false;
  String? _nameError;
  String? _nimError;
  String? _waError;
  String? _passError;
  String? _confirmError;

  void _register() async {
    setState(() {
      _nameError = null;
      _nimError = null;
      _waError = null;
      _passError = null;
      _confirmError = null;
    });

    final name = _nameCtrl.text.trim();
    final nim = _nimCtrl.text.trim();
    final wa = _waCtrl.text.trim();
    final pass = _passCtrl.text;
    final conf = _confirmCtrl.text;

    // Auto-convert 08xxx to 628xxx
    final formattedWa = wa.startsWith('0') ? '62${wa.substring(1)}' : wa;

    bool hasError = false;
    if (name.isEmpty) {
      setState(() => _nameError = 'Nama wajib diisi');
      hasError = true;
    }
    if (nim.isEmpty) {
      setState(() => _nimError = 'NIM wajib diisi');
      hasError = true;
    }
    if (wa.isEmpty) {
      setState(() => _waError = 'Nomor WhatsApp wajib diisi');
      hasError = true;
    }
    if (pass.isEmpty) {
      setState(() => _passError = 'Password wajib diisi');
      hasError = true;
    } else if (pass.length < 8) {
      setState(() => _passError = 'Password minimal 8 karakter');
      hasError = true;
    }
    if (pass != conf) {
      setState(() => _confirmError = 'Konfirmasi password tidak sama');
      hasError = true;
    }
    if (hasError) return;

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
      final errMsg = e.toString().toLowerCase();
      if (errMsg.contains('unique') || errMsg.contains('duplicate')) {
        AppToast.error(context, 'NIM sudah terdaftar. Gunakan NIM yang lain.');
      } else {
        AppToast.error(context, 'Gagal mendaftar. Silakan coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                  InkWell(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/get-started', (_) => false),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
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
                  CustomTextField(
                    label: 'Nama Lengkap',
                    controller: _nameCtrl,
                    hint: 'Masukkan nama lengkap',
                    prefixIcon: Icons.person_outline,
                    errorText: _nameError,
                  ),
                  const SizedBox(height: 16),

                  // NIM
                  CustomTextField(
                    label: 'NIM',
                    controller: _nimCtrl,
                    hint: 'Masukkan NIM',
                    prefixIcon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    errorText: _nimError,
                  ),
                  const SizedBox(height: 16),

                  // WhatsApp
                  CustomTextField(
                    label: 'Nomor WhatsApp',
                    controller: _waCtrl,
                    hint: '08XXXXXXXXXX',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    errorText: _waError,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  CustomTextField(
                    label: 'Password',
                    controller: _passCtrl,
                    hint: 'Minimal 8 karakter',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_showPass,
                    errorText: _passError,
                    suffixIcon: IconButton(
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
                  CustomTextField(
                    label: 'Konfirmasi Password',
                    controller: _confirmCtrl,
                    hint: 'Ulangi password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_showConfirmPass,
                    errorText: _confirmError,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _showConfirmPass = !_showConfirmPass),
                      icon: Icon(
                        _showConfirmPass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Button
                  CustomButton(
                    label: 'Daftar Sekarang',
                    onPressed: _register,
                    isLoading: _isLoading,
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
                        InkWell(
                          onTap: () => Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (_) => false),
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF27AE60),
                              ),
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
