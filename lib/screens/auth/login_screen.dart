import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nimCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  String? _nimError;
  String? _passError;

  void _login() async {
    setState(() {
      _nimError = null;
      _passError = null;
    });

    bool hasError = false;
    if (_nimCtrl.text.trim().isEmpty) {
      setState(() => _nimError = 'NIM wajib diisi');
      hasError = true;
    }
    if (_passCtrl.text.isEmpty) {
      setState(() => _passError = 'Password wajib diisi');
      hasError = true;
    }
    if (hasError) return;

    setState(() => _isLoading = true);
    try {
      final user = await AuthService().login(
        _nimCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      if (user == null) {
        AppToast.error(context, 'NIM atau password salah');
        return;
      }
      AppToast.success(context, 'Login berhasil! Selamat datang 👋');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Gagal masuk. Silakan coba lagi.');
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
                  const SizedBox(height: 48),

                  // Title
                  const Text(
                    'Masuk 👋',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masuk ke akun SAMBA kamu',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 40),

                  // NIM
                  CustomTextField(
                    label: 'NIM',
                    controller: _nimCtrl,
                    hint: 'Masukkan NIM',
                    prefixIcon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    errorText: _nimError,
                  ),
                  const SizedBox(height: 20),

                  // Password
                  CustomTextField(
                    label: 'Password',
                    controller: _passCtrl,
                    hint: 'Masukkan password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_showPassword,
                    errorText: _passError,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        AppToast.info(context,
                            'Hubungi admin kampus untuk reset password');
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Lupa password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Button
                  CustomButton(
                    label: 'Masuk',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 28),

                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                        InkWell(
                          onTap: () =>
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/register', (_) => false),
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Daftar',
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
    _nimCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
