// lib/screens/vendor_dashboard/offering_details_screen.dart

import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:softwareGP/theme/colors.dart';

import '../../models/offering.dart';
import '../../providers/auth_provider.dart';
import '../../providers/offering_provider.dart';

class OfferingDetailsScreen extends ConsumerWidget {
  final Offering offering; // Offering object to display details for
  const OfferingDetailsScreen({Key? key, required this.offering}) // 
    : super(key: key);

  Widget _buildStack(BuildContext context, Widget child) {
    return Stack(
      children: [
        //  function Background blur or color
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gradientStart,
                const Color.fromARGB(255, 244, 168, 196),
              ],
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
      return Scaffold(body: _buildStack(context, _buildLoginRequired())); // if user is not authenticated, show login required message
    }
    final vendorId = user.id;
    final isOwner = user.role == 'vendor' && vendorId == offering.vendorId;
    final isAdmin = user.role == 'admin';
    final host = kIsWeb ? 'localhost' : '192.168.1.107';
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
              onPressed: () async { // زر الحذف
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
                              style: TextStyle(
                                color: const Color.fromARGB(255, 244, 168, 196),
                              ),
                            ),
                          ),
                          ElevatedButton( // زر الحذف
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
          if (isOwner || isAdmin) // زر التعديل
            IconButton(
              icon: Icon(Icons.edit, color: accent1),
              onPressed: () async {
                await _showEditOfferingDialog(context, ref, vendorId, offering);
              },
            ),
        ],
      ),
      body: _buildStack( // Build the main content stack
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
                      Icons.card_giftcard, // Placeholder icon if no images
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
                  offering.title, // Title of the offering
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
                  '${offering.price.toStringAsFixed(2)} ش.إ', // Price of the offering
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 244, 168, 196),
                  ),
                ),
              ),
              // Description
              if (offering.description?.isNotEmpty ?? false) // Check if description exists , if null برجع false
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

  Widget _buildLoginRequired() => Center( // Message to show if user is not authenticated
    child: Text(
      'يجب تسجيل الدخول أولاً',
      style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
    ),
  );

  Future<void> _showEditOfferingDialog( // Show dialog to edit offering
    BuildContext context,
    WidgetRef ref,
    String vendorId,
    Offering off,
  ) async {
    final titleCtl = TextEditingController(text: off.title); // title controller
    final descCtl = TextEditingController(text: off.description); 
    final priceCtl = TextEditingController(text: off.price.toString());
    List<File> newImages = []; // List to hold new images

    Future<List<File>?> pickImages() async {
      return await showModalBottomSheet<List<File>>( // Show bottom sheet to pick images
        context: context,
        builder: (ctx) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: const Color.fromARGB(255, 244, 168, 196),
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
                    color: const Color.fromARGB(255, 244, 168, 196),
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

    await showDialog( // نافذة التعديل
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: Text(
            'تعديل العرض',
            style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
          ),
          content: SingleChildScrollView( // Scrollable content for the dialog
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
                    backgroundColor: const Color.fromARGB(255, 244, 168, 196),
                  ),
                  icon: Icon(Icons.photo_library, color: Colors.white), // Button to change/add images
                  label: Text(
                    'تغيير / إضافة صور',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async { // Open image picker تعرض واجهة اختيار الصور من المعرض او الكاميرا
                    final picked = await pickImages();
                    if (picked != null && picked.isNotEmpty) newImages = picked;
                  },
                ),
                if (newImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${newImages.length} صورة/صور مختارة', // تخزن الصورة في newImages ويعرض عدد الصور المختارة
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
                backgroundColor: const Color.fromARGB(255, 244, 168, 196),
              ),
              onPressed: () { // Save changes
                final t = titleCtl.text.trim(); // Get trimmed title
                final pr = double.tryParse(priceCtl.text.trim()) ?? off.price; // يحول النص الى رقم عشري 
                final d =
                    descCtl.text.trim().isEmpty ? null : descCtl.text.trim(); // اذا فارغ بحول النص الى null
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
 
  Widget _dialogField({   // انشاء حقل نصي بتصميم موحد
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
