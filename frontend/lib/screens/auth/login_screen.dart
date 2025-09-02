// lib/screens/auth/login_screen.dart

import 'dart:ui'; // Import necessary packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:softwareGP/providers/auth_provider.dart'; // يحتوي على المنطق الخاص بالمصادقة (Login / Register)  .


import 'package:softwareGP/screens/dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState(); //create object of state class
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(); // Text controller for email input
  final _passCtrl =
      TextEditingController(); // Text controller for password input
  bool _submitting =
      false; // wait flag for form submission , اذا كان ترو بكون لودنج او اذا فولس بظهر نص الزر

  @override
  //نستخدم dispose() لحذف الـ controllers وتفريغ الذاكرة:
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // Handles form submission when the user taps the "login button"
  Future<void> _submit() async {
    final email =
        _emailCtrl.text
            .trim(); //read email input and trim whitespace (TextEditingController)
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال البريد وكلمة المرور'),
        ), // Show error if fields are empty
      );
      return; //بوقف الدالة لانه فاضيين
    }
    setState(() => _submitting = true); //بحدث واجهة المستخدم لتعرض جاري التحميل
    await ref //  obj Access the auth notifier provider
        .read(authNotifierProvider.notifier)
        .login(email: email, password: pass);
    setState(() => _submitting = false); //بعد انتهاء عملية تسجيل الدخول
  }

  @override
  Widget build(BuildContext context) {
    //function Build the login screen UI
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacement(
          //استبدال الشاشة الحالية بشاشة جديدة
          MaterialPageRoute(
            builder:
                (_) => DashboardScreen(
                  user: next.user!,
                ), // Pass the authenticated user to the dashboard
          ), // Navigate to dashboard on successful login
        );
      }
    });

    final authState = ref.watch(
      authNotifierProvider,
    ); //براقب الحالة  اذا تغيرت البيانات مباشرة بعيد البناء للواجهة
    final accent1 = const Color.fromRGBO(183, 162, 143, 1);
    ;
    final accent2 = const Color.fromARGB(255, 244, 168, 196);

    //الهيكل الرئيسي
    return Scaffold(
      body: Stack(
        // Stack to layer background, blur, and form
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
                    'Tripify  ',
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
                            // Build email input field function
                            controller:
                                _emailCtrl, // TextEditingController for email
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
                            obscure: true, // Hide password input
                          ),
                          const SizedBox(height: 24),
                          // Login button
                          SizedBox(
                            width: double.infinity, // Full width button
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
                                            //دوران لودينج
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
                              ref
                                  .watch(authNotifierProvider)
                                  .message!, // Display error message if login fails from provider
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
                            builder:
                                (_) =>
                                    const RegisterScreen(), // Navigate to registration screen
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
    // Function to build input fields
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
