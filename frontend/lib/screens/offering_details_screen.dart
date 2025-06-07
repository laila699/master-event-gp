import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/offering.dart';
import '../../providers/auth_provider.dart';
import '../../providers/offering_provider.dart';

/// Shows a single Offering in detail:
///  • Carousel of images (if any)
///  • Title, Price, Description
///  • If current user is the vendor who owns it (or an admin), show “Edit” / “Delete”
///    otherwise read-only.
class OfferingDetailsScreen extends ConsumerWidget {
  final Offering offering;

  const OfferingDetailsScreen({Key? key, required this.offering})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user =
        authState.status == AuthStatus.authenticated ? authState.user! : null;
    final isVendorOwner =
        user != null && user.role == 'vendor' && user.id == offering.vendorId;
    final isAdmin = user != null && user.role == 'admin';

    // Base URL for loading “offering.images[ ]” (adjust host if needed)
    final host = '172.16.0.120';
    final base = 'http://$host:5000';

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل العرض'),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (isVendorOwner || isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: const Text(
                          'هل أنت متأكد أنك تريد حذف هذا العرض؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  // Call delete from notifier, then pop back to list
                  await ref
                      .read(vendorOfferingsProvider.notifier)
                      .deleteExisting(offeringId: offering.id);
                  Navigator.of(context).pop(); // back to list
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('تم حذف العرض')));
                }
              },
            ),
          if (isVendorOwner || isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Reuse your existing edit dialog logic
                await _showEditOfferingDialog(context, ref, offering);
                // After editing, rebuild so that updated data is shown
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Images carousel (if any)
            if (offering.images.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: offering.images.length,
                  itemBuilder: (ctx, i) {
                    final imgPath = offering.images[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '$base$imgPath',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.card_giftcard,
                    color: Colors.grey,
                    size: 80,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 2) Title & Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                offering.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                '${offering.price.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 3) Description (if any)
            if (offering.description != null &&
                offering.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  offering.description!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Exactly the same edit‐dialog you already have in OfferingTab.
  Future<void> _showEditOfferingDialog(
    BuildContext context,
    WidgetRef ref,
    Offering off,
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
                    if (img != null) {
                      Navigator.of(ctx).pop([File(img.path)]);
                    } else {
                      Navigator.of(ctx).pop(<File>[]);
                    }
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
                          setState(() {
                            _newImages = picked;
                          });
                        }
                      },
                    ),
                    if (_newImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${_newImages.length} صورة/صور مختارة',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
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
                          .read(vendorOfferingsProvider.notifier)
                          .updateExisting(
                            offeringId: off.id,
                            title: title,
                            description: desc,
                            price: price,
                            newImages: _newImages,
                          );
                      Navigator.of(ctx).pop();
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
