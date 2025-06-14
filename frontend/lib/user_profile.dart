// lib/screens/profile_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/screens/auth/login_screen.dart';
import 'package:masterevent/theme/colors.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _pickedImage;
  final _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final picked = await _picker.pickImage(source: src, imageQuality: 75);
      if (picked != null && mounted) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
        );
        Navigator.of(context).pop(); // 👈 go back to previous page
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.gradientEnd,
                  ),
                  title: const Text('اختيار من المعرض'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                    color: AppColors.gradientEnd,
                  ),
                  title: const Text('التقاط صورة'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    setState(() => _isSaving = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .updateProfile(
            name: name,
            email: email,
            phone: phone,
            profileImage: _pickedImage,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
        );
      }
    } catch (_) {
      // errors handled by authState listener
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final host = '192.168.1.122';
    // On iOS Simulator, localhost will work; on Android emulator you must use 10.0.2.2
    final base = 'http://$host:5000/api';
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (prev?.status != AuthStatus.unauthenticated &&
          next.status == AuthStatus.unauthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        });
      }
    });

    final accent1 = AppColors.gradientStart;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_nameController.text.isEmpty) _nameController.text = user.name;
    if (_emailController.text.isEmpty) _emailController.text = user.email;
    if (_phoneController.text.isEmpty) _phoneController.text = user.phone;
    if (authState.status == AuthStatus.error && authState.message != null) {
      Future.microtask(() {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authState.message!)));
      });
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.overlay,
        elevation: 0,
        automaticallyImplyLeading: true, // 👈 enables the default back button
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'الملف الشخصي',
          style: GoogleFonts.orbitron(color: Colors.white),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [accent1, AppColors.background],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: AppColors.glass,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.fieldFill,
                                backgroundImage:
                                    _pickedImage != null
                                        ? FileImage(_pickedImage!)
                                        : (user.avatarUrl != null
                                                ? NetworkImage(
                                                  '${base}${user.avatarUrl}',
                                                )
                                                : null)
                                            as ImageProvider<Object>?,
                                child:
                                    (_pickedImage == null &&
                                            user.avatarUrl == null)
                                        ? Text(
                                          user.name.isNotEmpty
                                              ? user.name[0]
                                              : 'U',
                                          style: TextStyle(
                                            fontSize: 50,
                                            color: AppColors.textSecondary,
                                          ),
                                        )
                                        : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Material(
                                  color: AppColors.gradientEnd,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: _showImageSourceDialog,
                                    customBorder: const CircleBorder(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          controller: _nameController,
                          label: 'الاسم الكامل',
                          icon: Icons.person_outline,
                          accent: accent1,
                          validator:
                              (v) =>
                                  v!.trim().isEmpty
                                      ? 'الرجاء إدخال الاسم الكامل'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          accent: accent1,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _phoneController,
                          label: 'رقم الهاتف',
                          icon: Icons.phone_outlined,
                          accent: accent1,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v!.trim().isEmpty)
                              return 'الرجاء إدخال رقم الهاتف';
                            return v.trim().length >= 9
                                ? null
                                : 'رقم الهاتف قصير جدًا';
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon:
                                _isSaving
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.save,
                                      color: Colors.white,
                                    ),
                            label: Text(
                              _isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent1,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isSaving ? null : _saveProfile,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: Icon(Icons.logout, color: AppColors.error),
                          title: Text(
                            'تسجيل الخروج',
                            style: GoogleFonts.orbitron(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            ref.read(authNotifierProvider.notifier).logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color accent,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: accent),
        filled: true,
        fillColor: AppColors.fieldFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
