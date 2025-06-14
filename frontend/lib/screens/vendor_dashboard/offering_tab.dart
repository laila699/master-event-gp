// lib/screens/vendor_dashboard/offering_tab.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:masterevent/providers/auth_provider.dart'
    show authNotifierProvider, AuthStatus;
import 'package:masterevent/screens/create_booking_screen.dart';
import 'package:masterevent/screens/offering_details_screen.dart';
import 'package:masterevent/theme/colors.dart';
import '../../models/offering.dart';
import '../../providers/offering_provider.dart';

/// Displays the vendor’s offerings in a ListView, with Add/Edit/Delete.
class OfferingTab extends ConsumerWidget {
  final String vendorId;
  const OfferingTab({Key? key, required this.vendorId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(vendorOfferingsProvider(vendorId));
    final auth = ref.watch(authNotifierProvider);
    final user = auth.status == AuthStatus.authenticated ? auth.user : null;
    final isVendor = user?.role == 'vendor' && user?.id == vendorId;
    final isAdmin = user?.role == 'admin';
    final canEdit = isVendor == true || isAdmin == true;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Neon radial background
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [AppColors.gradientStart, AppColors.background],
              ),
            ),
          ),
          // Glass blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),
          offeringsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, _) => Center(
                  child: Text(
                    'خطأ: $err',
                    style: GoogleFonts.orbitron(color: AppColors.error),
                  ),
                ),
            data: (offerings) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: offerings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final off = offerings[index];
                    return _buildOfferingTile(context, ref, off, canEdit);
                  },
                ),
                floatingActionButton:
                    canEdit
                        ? FloatingActionButton(
                          backgroundColor: AppColors.gradientEnd,
                          child: Icon(Icons.add, color: AppColors.textOnNeon),
                          onPressed:
                              () => _showCreateOfferingDialog(
                                context,
                                ref,
                                vendorId,
                              ),
                        )
                        : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingTile(
    BuildContext context,
    WidgetRef ref,
    Offering off,
    bool canEdit,
  ) {
    final host = '192.168.1.122';
    final base = 'http://$host:5000/api';
    return Card(
      color: AppColors.glass,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OfferingDetailsScreen(offering: off),
            ),
          );
        },
        leading:
            off.images.isEmpty
                ? Icon(
                  Icons.card_giftcard,
                  size: 40,
                  color: AppColors.textSecondary,
                )
                : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '$base${off.images.first}',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
        title: Text(
          off.title,
          style: GoogleFonts.orbitron(
            color: AppColors.textOnNeon,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${off.price.toStringAsFixed(2)} ش.إ',
          style: GoogleFonts.orbitron(
            color: AppColors.gradientEnd,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:
            canEdit
                ? _editDeleteActions(context, ref, off, off.vendorId)
                : _bookingButton(context, off),
      ),
    );
  }

  Widget _editDeleteActions(
    BuildContext context,
    WidgetRef ref,
    Offering off,
    String vendorId,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: AppColors.gradientStart),
          onPressed: () => _showEditOfferingDialog(context, ref, off, vendorId),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            ref
                .read(vendorOfferingsProvider(vendorId).notifier)
                .deleteExisting(offeringId: off.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم حذف العرض')));
          },
        ),
      ],
    );
  }

  Widget _bookingButton(BuildContext context, Offering off) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gradientStart,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CreateBookingScreen(offering: off)),
        );
      },
      child: Text(
        'احجز',
        style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
      ),
    );
  }

  Future<void> _showCreateOfferingDialog(
    BuildContext context,
    WidgetRef ref,
    String vendorId,
  ) async {
    final _titleCtl = TextEditingController();
    final _descCtl = TextEditingController();
    final _priceCtl = TextEditingController();
    List<File> _selectedImages = [];

    Future<List<File>?> _pickImages() async {
      return await showModalBottomSheet<List<File>>(
        context: context,
        builder: (ctx) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('اختيار من المعرض'),
                  onTap: () async {
                    final pickedFiles = await ImagePicker().pickMultiImage(
                      imageQuality: 75,
                    );
                    final result =
                        (pickedFiles ?? []).map((e) => File(e.path)).toList();
                    Navigator.of(ctx).pop(result);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('التقاط صورة'),
                  onTap: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 75,
                    );
                    Navigator.of(
                      ctx,
                    ).pop(picked != null ? [File(picked.path)] : <File>[]);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: AppColors.glass,
              title: const Text('إنشاء عرض جديد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleCtl,
                      decoration: const InputDecoration(labelText: 'العنوان'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descCtl,
                      decoration: const InputDecoration(
                        labelText: 'الوصف (اختياري)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceCtl,
                      decoration: const InputDecoration(labelText: 'السعر'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('اختيار / التقاط صور'),
                      onPressed: () async {
                        final picked = await _pickImages();
                        if (picked != null && picked.isNotEmpty) {
                          setState(() => _selectedImages = picked);
                        }
                      },
                    ),
                    if (_selectedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${_selectedImages.length} صورة/صور مختارة',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleCtl.text.trim();
                    final price = double.tryParse(_priceCtl.text.trim()) ?? 0;
                    final desc =
                        _descCtl.text.trim().isEmpty
                            ? null
                            : _descCtl.text.trim();
                    if (title.isNotEmpty && price > 0) {
                      ref
                          .read(vendorOfferingsProvider(vendorId).notifier)
                          .addOffering(
                            title: title,
                            description: desc,
                            price: price,
                            images: _selectedImages,
                          );
                      Navigator.of(dialogCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جارٍ إنشاء العرض...')),
                      );
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditOfferingDialog(
    BuildContext context,
    WidgetRef ref,
    Offering off,
    String vendorId,
  ) async {
    final _titleCtl = TextEditingController(text: off.title);
    final _descCtl = TextEditingController(text: off.description);
    final _priceCtl = TextEditingController(text: off.price.toString());
    List<File> _newImages = [];

    Future<List<File>?> _pickNewImages() async {
      return await showModalBottomSheet<List<File>>(
        context: context,
        builder: (ctx) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('اختيار من المعرض'),
                  onTap: () async {
                    final imgs = await ImagePicker().pickMultiImage(
                      imageQuality: 75,
                    );
                    final result =
                        (imgs ?? []).map((e) => File(e.path)).toList();
                    Navigator.of(ctx).pop(result);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('التقاط صورة جديدة'),
                  onTap: () async {
                    final img = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 75,
                    );
                    Navigator.of(
                      ctx,
                    ).pop(img != null ? [File(img.path)] : <File>[]);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: AppColors.glass,
              title: const Text('تعديل العرض'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleCtl,
                      decoration: const InputDecoration(labelText: 'العنوان'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descCtl,
                      decoration: const InputDecoration(
                        labelText: 'الوصف (اختياري)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceCtl,
                      decoration: const InputDecoration(labelText: 'السعر'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('تغيير / إضافة صور'),
                      onPressed: () async {
                        final picked = await _pickNewImages();
                        if (picked != null && picked.isNotEmpty) {
                          setState(() => _newImages = picked);
                        }
                      },
                    ),
                    if (_newImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${_newImages.length} صورة/صور مختارة',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleCtl.text.trim();
                    final desc =
                        _descCtl.text.trim().isEmpty
                            ? null
                            : _descCtl.text.trim();
                    final price =
                        double.tryParse(_priceCtl.text.trim()) ?? off.price;
                    if (title.isNotEmpty && price > 0) {
                      ref
                          .read(vendorOfferingsProvider(vendorId).notifier)
                          .updateExisting(
                            offeringId: off.id,
                            title: title,
                            description: desc,
                            price: price,
                            newImages: _newImages,
                          );
                      Navigator.of(dialogCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جارٍ تحديث العرض...')),
                      );
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
