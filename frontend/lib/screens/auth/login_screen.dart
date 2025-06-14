// lib/screens/auth/login_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/providers/auth_provider.dart';
import 'package:masterevent/screens/dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد وكلمة المرور')),
      );
      return;
    }
    setState(() => _submitting = true);
    await ref
        .read(authNotifierProvider.notifier)
        .login(email: email, password: pass);
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardScreen(user: next.user!)),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final accent1 = const Color(0xFFD81B60); // magenta-pink
    final accent2 = const Color(0xFF8E24AA); // deep purple

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1) Neon radial background
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.5),
                radius: 1.2,
                colors: [accent1, Colors.black],
              ),
            ),
          ),
          // 2) Glassmorphic blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          // 3) Centered form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // logo
                  Icon(Icons.event, size: 80, color: accent2.withOpacity(0.8)),
                  const SizedBox(height: 24),
                  Text(
                    'Master Event ',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      color: accent1,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Glass card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      color: Colors.white.withOpacity(0.05),
                      child: Column(
                        children: [
                          // Email
                          _buildField(
                            controller: _emailCtrl,
                            hint: 'البريد الإلكتروني',
                            icon: Icons.email,
                            accent: accent2,
                          ),
                          const SizedBox(height: 16),
                          // Password
                          _buildField(
                            controller: _passCtrl,
                            hint: 'كلمة المرور',
                            icon: Icons.lock,
                            accent: accent2,
                            obscure: true,
                          ),
                          const SizedBox(height: 24),
                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accent1, accent2],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent2.withOpacity(0.6),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _submitting ? null : _submit,
                                child:
                                    _submitting
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Text(
                                          'تسجيل الدخول',
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Error message
                          if (ref.watch(authNotifierProvider).status ==
                              AuthStatus.error)
                            Text(
                              ref.watch(authNotifierProvider).message!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Register link
                  TextButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                    child: Text(
                      'إنشاء حساب جديد',
                      style: GoogleFonts.orbitron(color: accent2, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'بالاستمرار، أنت توافق على الشروط وسياسة الخصوصية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color accent,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: accent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent.withOpacity(0.6), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}
