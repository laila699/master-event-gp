// lib/screens/auth/register_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:masterevent/providers/auth_provider.dart';
import 'package:masterevent/screens/auth/login_screen.dart';
import 'package:masterevent/screens/dashboard_screen.dart';
import 'package:masterevent/screens/my_events_screen.dart';
import 'package:masterevent/models/user.dart';

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
  const RegisterScreen({super.key});

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

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (picked != null) {
        setState(() {
          _profileImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );
      if (picked != null) {
        setState(() {
          _profileImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء التقاط الصورة')),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final role = _selectedRole;

    VendorProfile? vendorProfile;
    if (role == 'vendor') {
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
            password: password,
            role: role,
            profileImage: _profileImage,
            vendorProfile: vendorProfile,
          );
      // Navigation is handled by ref.listen below
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

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Profile Picture Picker ──
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child:
                      _profileImage == null
                          ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 16),

              // ── Name Field ──
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الاسم الكامل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Email Field ──
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال البريد الإلكتروني';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'صيغة البريد الإلكتروني غير صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Phone Field ──
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  if (value.trim().length < 9) {
                    return 'رقم الهاتف قصير جدًا';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Password Field ──
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال كلمة المرور';
                  }
                  if (value.length < 6) {
                    return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Role Dropdown & Icon ──
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
                        if (val != null) {
                          setState(() {
                            _selectedRole = val;
                            if (_selectedRole != 'vendor') {
                              _selectedVendorType = null;
                            } else {
                              _selectedVendorType = _allVendorTypes.first;
                            }
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'اختر دورك',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    _selectedRole == 'organizer'
                        ? Icons.person
                        : Icons.storefront,
                    size: 32,
                    color: Colors.deepPurple,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Vendor Service Type (only if role == 'vendor') ──
              if (_selectedRole == 'vendor') ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اختر نوع الخدمة:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedVendorType,
                  items:
                      _allVendorTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_vendorTypeLabels[type]!),
                        );
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedVendorType = val);
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedRole == 'vendor' && value == null) {
                      return 'الرجاء اختيار نوع الخدمة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // ── Register Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('إنشاء حساب'),
                ),
              ),
              const SizedBox(height: 12),

              // ── Friendly Error Message ──
              if (authState.status == AuthStatus.error)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    authState.message!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),

              // ── Navigate back to LoginScreen ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لديك حساب بالفعل؟'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
