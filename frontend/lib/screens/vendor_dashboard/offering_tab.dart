// lib/screens/vendor_dashboard/offering_tab.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masterevent/screens/offering_details_screen.dart';

import '../../models/offering.dart';
import '../../providers/offering_provider.dart';

/// Displays the vendor’s offerings in a ListView, with Add/Edit/Delete.
class OfferingTab extends ConsumerWidget {
  const OfferingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(vendorOfferingsProvider);
    final host = '172.16.0.120';
    // On iOS Simulator, localhost will work; on Android emulator you must use 10.0.2.2
    final base = 'http://$host:5000/api';

    return offeringsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('خطأ: $err')),
      data: (offerings) {
        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: offerings.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final off = offerings[index];
                return ListTile(
                  leading:
                      off.images.isEmpty
                          ? const Icon(
                            Icons.card_giftcard,
                            size: 40,
                            color: Colors.grey,
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              '${base}${off.images.first}',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                  title: Text(
                    off.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${off.price.toStringAsFixed(2)} ر.س',
                    style: TextStyle(color: Colors.deepPurple.shade700),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.deepPurple),
                        onPressed: () async {
                          await _showEditOfferingDialog(context, ref, off);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(vendorOfferingsProvider.notifier)
                              .deleteExisting(offeringId: off.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم حذف العرض')),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OfferingDetailsScreen(offering: off),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.add),
                onPressed: () async {
                  await _showCreateOfferingDialog(context, ref);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Dialog to create a new offering:
  Future<void> _showCreateOfferingDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final _titleCtl = TextEditingController();
    final _descCtl = TextEditingController();
    final _priceCtl = TextEditingController();
    List<File> _selectedImages = [];

    // This helper actually brings up a bottom‐sheet to pick images:
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
                    // Pick multiple from gallery:
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
                    if (picked != null) {
                      Navigator.of(ctx).pop([File(picked.path)]);
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
                          setState(() {
                            _selectedImages = picked;
                          });
                        }
                      },
                    ),
                    if (_selectedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${_selectedImages.length} صورة/صور مختارة',
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
                    final price = double.tryParse(_priceCtl.text.trim()) ?? 0;
                    final desc =
                        _descCtl.text.trim().isEmpty
                            ? null
                            : _descCtl.text.trim();
                    if (title.isNotEmpty && price > 0) {
                      ref
                          .read(vendorOfferingsProvider.notifier)
                          .addOffering(
                            title: title,
                            description: desc,
                            price: price,
                            images: _selectedImages,
                          );
                      Navigator.of(ctx).pop();
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

  /// Dialog to edit an existing offering:
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
