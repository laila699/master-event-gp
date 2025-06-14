// lib/screens/auth/register_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/providers/auth_provider.dart';
import 'package:masterevent/screens/auth/login_screen.dart';
import 'package:masterevent/screens/dashboard_screen.dart';
import 'package:masterevent/models/user.dart';
import 'package:masterevent/theme/colors.dart';

/// These must match exactly the backend enum values:
const List<String> _allVendorTypes = [
  'decorator',
  'interior_designer',
  'furniture_store',
  'photographer',
  'restaurant',
  'gift_shop',
  'entertainer',
];

const Map<String, String> _vendorTypeLabels = {
  'decorator': 'ديكور',
  'interior_designer': 'مصمم داخلي',
  'furniture_store': 'متجر أثاث',
  'photographer': 'مصور',
  'restaurant': 'مطعم',
  'gift_shop': 'متجر هدايا',
  'entertainer': 'منشط',
};

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _profileImage;
  final _picker = ImagePicker();
  String _selectedRole = 'organizer';
  String? _selectedVendorType = _allVendorTypes.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final picked = await _picker.pickImage(source: src, imageQuality: 75);
      if (picked != null) setState(() => _profileImage = File(picked.path));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر اختيار الصورة')));
    }
  }

  void _showImageSourceSheet() => showModalBottomSheet(
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text;
    VendorProfile? vendorProfile;
    if (_selectedRole == 'vendor') {
      if (_selectedVendorType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار نوع البائع')),
        );
        return;
      }
      vendorProfile = VendorProfile(serviceType: _selectedVendorType!);
    }
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .register(
            name: name,
            email: email,
            phone: phone,
            password: pass,
            role: _selectedRole,
            profileImage: _profileImage,
            vendorProfile: vendorProfile,
          );
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardScreen(user: next.user!)),
        );
      }
    });

    final accent1 = AppColors.gradientStart;
    final accent2 = AppColors.gradientEnd;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.5),
                radius: 1.2,
                colors: [accent1, AppColors.background],
              ),
            ),
          ),
          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: AppColors.overlay),
          ),
          // Form card
          Center(
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
                        // Profile picture
                        GestureDetector(
                          onTap: _showImageSourceSheet,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.fieldFill,
                            backgroundImage:
                                _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                            child:
                                _profileImage == null
                                    ? Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: accent2,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Name
                        _buildTextField(
                          controller: _nameController,
                          label: 'الاسم الكامل',
                          icon: Icons.person,
                          accent: accent1,
                          validator:
                              (v) =>
                                  v!.trim().isEmpty
                                      ? 'الرجاء إدخال الاسم الكامل'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        // Email
                        _buildTextField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email,
                          accent: accent1,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        // Phone
                        _buildTextField(
                          controller: _phoneController,
                          label: 'رقم الهاتف',
                          icon: Icons.phone,
                          accent: accent1,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v!.trim().isEmpty)
                              return 'الرجاء إدخال رقم الهاتف';
                            return v.trim().length < 9
                                ? 'رقم الهاتف قصير جدًا'
                                : null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password
                        _buildTextField(
                          controller: _passwordController,
                          label: 'كلمة المرور',
                          icon: Icons.lock,
                          accent: accent1,
                          obscure: true,
                          validator: (v) {
                            if (v!.isEmpty) return 'الرجاء إدخال كلمة المرور';
                            return v.length < 6
                                ? 'يجب أن تكون كلمة المرور 6 أحرف على الأقل'
                                : null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Role dropdown
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedRole,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'organizer',
                                    child: Text('منظم (Organizer)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'vendor',
                                    child: Text('بائع (Vendor)'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() {
                                      _selectedRole = val;
                                      _selectedVendorType =
                                          (val == 'vendor')
                                              ? _allVendorTypes.first
                                              : null;
                                    });
                                },
                                decoration: InputDecoration(
                                  labelText: 'اختر دورك',
                                  prefixIcon: Icon(Icons.group, color: accent1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                        if (_selectedRole == 'vendor') ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'اختر نوع الخدمة:',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedVendorType,
                            items:
                                _allVendorTypes
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(_vendorTypeLabels[type]!),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) =>
                                    setState(() => _selectedVendorType = val),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator:
                                (v) =>
                                    (v == null)
                                        ? 'الرجاء اختيار نوع الخدمة'
                                        : null,
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Register button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent1,
                              foregroundColor: AppColors.textOnNeon,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _submit,
                            child:
                                _isSubmitting
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      'إنشاء حساب',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                          ),
                        ),
                        if (ref.watch(authNotifierProvider).status ==
                            AuthStatus.error) ...[
                          const SizedBox(height: 16),
                          Text(
                            ref.watch(authNotifierProvider).message!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'لديك حساب بالفعل؟',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            TextButton(
                              onPressed:
                                  () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  ),
                              child: Text(
                                'تسجيل الدخول',
                                style: GoogleFonts.orbitron(color: accent2),
                              ),
                            ),
                          ],
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

  Widget _buildTextField({
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
