// lib/screens/vendor_dashboard/offering_details_screen.dart

import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/theme/colors.dart';

import '../../models/offering.dart';
import '../../providers/auth_provider.dart';
import '../../providers/offering_provider.dart';

class OfferingDetailsScreen extends ConsumerWidget {
  final Offering offering;
  const OfferingDetailsScreen({Key? key, required this.offering})
    : super(key: key);

  Widget _buildStack(BuildContext context, Widget child) {
    return Stack(
      children: [
        // Background blur or color
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: AppColors.overlay.withOpacity(0.2)),
        ),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent1 = AppColors.gradientStart;
    final background = AppColors.background;
    final overlay = AppColors.overlay;
    final authState = ref.watch(authNotifierProvider);
    final user =
        authState.status == AuthStatus.authenticated ? authState.user! : null;
    if (user == null) {
      return Scaffold(body: _buildStack(context, _buildLoginRequired()));
    }
    final vendorId = user.id;
    final isOwner = user.role == 'vendor' && vendorId == offering.vendorId;
    final isAdmin = user.role == 'admin';
    final host = kIsWeb ? 'localhost' : '192.168.1.122';
    final base = 'http://$host:5000/api';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: overlay,
        elevation: 0,
        title: Text(
          'تفاصيل العرض',
          style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
        ),
        iconTheme: IconThemeData(color: AppColors.textOnNeon),
        actions: [
          if (isOwner || isAdmin)
            IconButton(
              icon: Icon(Icons.delete, color: accent1),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        backgroundColor: AppColors.glass,
                        title: Text(
                          'تأكيد الحذف',
                          style: GoogleFonts.orbitron(
                            color: AppColors.textOnNeon,
                          ),
                        ),
                        content: Text(
                          'هل أنت متأكد أنك تريد حذف هذا العرض؟',
                          style: GoogleFonts.orbitron(
                            color: AppColors.textOnNeon,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(color: AppColors.gradientEnd),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text('حذف'),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  await ref
                      .read(vendorOfferingsProvider(vendorId).notifier)
                      .deleteExisting(offeringId: offering.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('تم حذف العرض')));
                }
              },
            ),
          if (isOwner || isAdmin)
            IconButton(
              icon: Icon(Icons.edit, color: accent1),
              onPressed: () async {
                await _showEditOfferingDialog(context, ref, vendorId, offering);
              },
            ),
        ],
      ),
      body: _buildStack(
        context,
        SingleChildScrollView(
          padding: const EdgeInsets.only(top: kToolbarHeight + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image carousel
              if (offering.images.isNotEmpty)
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    itemCount: offering.images.length,
                    itemBuilder: (ctx, i) {
                      final img = offering.images[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network('$base$img', fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 250,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.card_giftcard,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              // Title & Price
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  offering.title,
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnNeon,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  '${offering.price.toStringAsFixed(2)} ش.إ',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gradientEnd,
                  ),
                ),
              ),
              // Description
              if (offering.description?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    offering.description!,
                    style: GoogleFonts.audiowide(
                      color: AppColors.textOnNeon,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginRequired() => Center(
    child: Text(
      'يجب تسجيل الدخول أولاً',
      style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
    ),
  );

  Future<void> _showEditOfferingDialog(
    BuildContext context,
    WidgetRef ref,
    String vendorId,
    Offering off,
  ) async {
    final titleCtl = TextEditingController(text: off.title);
    final descCtl = TextEditingController(text: off.description);
    final priceCtl = TextEditingController(text: off.price.toString());
    List<File> newImages = [];

    Future<List<File>?> pickImages() async {
      return await showModalBottomSheet<List<File>>(
        context: context,
        builder: (ctx) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: AppColors.gradientEnd,
                  ),
                  title: Text(
                    'اختيار من المعرض',
                    style: TextStyle(color: AppColors.textOnNeon),
                  ),
                  onTap: () async {
                    final imgs = await ImagePicker().pickMultiImage(
                      imageQuality: 75,
                    );
                    Navigator.pop(ctx, imgs?.map((e) => File(e.path)).toList());
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_camera,
                    color: AppColors.gradientEnd,
                  ),
                  title: Text(
                    'التقاط صورة جديدة',
                    style: TextStyle(color: AppColors.textOnNeon),
                  ),
                  onTap: () async {
                    final img = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 75,
                    );
                    Navigator.pop(
                      ctx,
                      img != null ? [File(img.path)] : <File>[],
                    );
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
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: Text(
            'تعديل العرض',
            style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  controller: titleCtl,
                  label: 'العنوان',
                  accent: AppColors.gradientStart,
                ),
                const SizedBox(height: 8),
                _dialogField(
                  controller: descCtl,
                  label: 'الوصف (اختياري)',
                  accent: AppColors.gradientStart,
                ),
                const SizedBox(height: 8),
                _dialogField(
                  controller: priceCtl,
                  label: 'السعر',
                  accent: AppColors.gradientStart,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gradientEnd,
                  ),
                  icon: Icon(Icons.photo_library, color: Colors.white),
                  label: Text(
                    'تغيير / إضافة صور',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    final picked = await pickImages();
                    if (picked != null && picked.isNotEmpty) newImages = picked;
                  },
                ),
                if (newImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${newImages.length} صورة/صور مختارة',
                      style: TextStyle(color: AppColors.textOnNeon),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'إلغاء',
                style: TextStyle(color: AppColors.gradientStart),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradientEnd,
              ),
              onPressed: () {
                final t = titleCtl.text.trim();
                final pr = double.tryParse(priceCtl.text.trim()) ?? off.price;
                final d =
                    descCtl.text.trim().isEmpty ? null : descCtl.text.trim();
                if (t.isNotEmpty && pr > 0) {
                  ref
                      .read(vendorOfferingsProvider(vendorId).notifier)
                      .updateExisting(
                        offeringId: off.id,
                        title: t,
                        description: d,
                        price: pr,
                        newImages: newImages,
                      );
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('جارٍ تحديث العرض...')),
                  );
                }
              },
              child: Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required Color accent,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textOnNeon),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
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
    );
  }
}
