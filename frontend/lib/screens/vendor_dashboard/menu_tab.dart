// lib/screens/vendor_dashboard/menu_tab.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masterevent/providers/auth_provider.dart';

import '../../models/menu_section.dart';

import '../../providers/restaurant_provider.dart';

class MenuTab extends ConsumerWidget {
  final String vendorId;
  const MenuTab({Key? key, required this.vendorId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(restaurantMenuProvider(vendorId));
    final host = '192.168.1.122';
    final base = 'http://$host:5000/api';

    // Determine roles
    final auth = ref.watch(authNotifierProvider);
    final user = auth.status == AuthStatus.authenticated ? auth.user : null;
    final isVendor = user?.role == 'vendor' && user?.id == vendorId;
    final isAdmin = user?.role == 'admin';
    final canEdit = isVendor == true || isAdmin == true;

    return menuAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (sections) {
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: sections.length,
              itemBuilder: (ctx, idx) {
                final section = sections[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ExpansionTile(
                    key: ValueKey(section.id),
                    title: Text(
                      section.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    children: [
                      // dishes
                      ...section.items.map((dish) {
                        return ListTile(
                          leading:
                              dish.imageUrl == null
                                  ? const Icon(
                                    Icons.restaurant_menu,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      '$base${dish.imageUrl}',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ),
                          title: Text(
                            dish.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${dish.price} ش.إ',
                            style: TextStyle(color: Colors.purple.shade600),
                          ),
                          trailing:
                              canEdit
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.purple,
                                        ),
                                        onPressed: () {
                                          _showEditDishDialog(
                                            context,
                                            ref,
                                            section.id,
                                            dish,
                                            vendorId,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(
                                                restaurantMenuProvider(
                                                  vendorId,
                                                ).notifier,
                                              )
                                              .deleteDish(
                                                sectionId: section.id,
                                                dishId: dish.id,
                                              );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('تم حذف الوجبة'),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                  : null,
                        );
                      }).toList(),

                      // add-dish button
                      if (canEdit)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة وجبة جديدة'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.purple,
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              _showAddDishDialog(
                                context,
                                ref,
                                section.id,
                                vendorId,
                              );
                            },
                          ),
                        ),

                      const Divider(height: 1),
                    ],
                  ),
                );
              },
            ),

            // add-section FAB
            if (canEdit)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: Colors.purple,
                  child: const Icon(Icons.add_business),
                  onPressed: () {
                    _showAddSectionDialog(context, ref, vendorId);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// 1) Dialog to add a new SECTION
  Future<void> _showAddSectionDialog(
    BuildContext context,
    WidgetRef ref,
    String vendorId,
  ) async {
    final _secCtl = TextEditingController();

    final sectionName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('إضافة قسم جديد'),
          content: TextField(
            controller: _secCtl,
            decoration: const InputDecoration(hintText: 'اسم القسم'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _secCtl.text.trim();
                Navigator.of(ctx).pop(name.isEmpty ? null : name);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );

    if (sectionName != null && sectionName.isNotEmpty) {
      ref
          .read(restaurantMenuProvider(vendorId).notifier)
          .addSection(name: sectionName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('جارٍ إضافة القسم "$sectionName"')),
      );
    }
  }

  /// 2) Dialog to add a new DISH under an existing section
  Future<void> _showAddDishDialog(
    BuildContext context,
    WidgetRef ref,
    String sectionId,
    String vendorId,
  ) async {
    final _nameCtl = TextEditingController();
    final _priceCtl = TextEditingController();
    File? _pickedImage;

    Future<File?> _pickImage() async {
      final picked = await showModalBottomSheet<File?>(
        context: context,
        builder: (ctx) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('اختيار صورة من المعرض'),
                  onTap: () async {
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 75,
                    );
                    Navigator.of(
                      ctx,
                    ).pop(file == null ? null : File(file.path));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('التقاط صورة بالكاميرا'),
                  onTap: () async {
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 75,
                    );
                    Navigator.of(
                      ctx,
                    ).pop(file == null ? null : File(file.path));
                  },
                ),
              ],
            ),
          );
        },
      );
      return picked;
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('إضافة وجبة جديدة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview chosen image (if any)
                    if (_pickedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            _pickedImage!,
                            width: 120,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('اختيار / التقاط صورة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final img = await _pickImage();
                        if (img != null) {
                          setState(() {
                            _pickedImage = img;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtl,
                      decoration: const InputDecoration(
                        labelText: 'اسم الوجبة',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceCtl,
                      decoration: const InputDecoration(
                        labelText: 'السعر (ش.إ)',
                      ),
                      keyboardType: TextInputType.number,
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
                    final name = _nameCtl.text.trim();
                    final priceText = _priceCtl.text.trim();
                    if (name.isNotEmpty && priceText.isNotEmpty) {
                      ref
                          .read(restaurantMenuProvider(vendorId).notifier)
                          .addDish(
                            sectionId: sectionId,
                            dishName: name,
                            dishPrice: priceText,
                            imageFile: _pickedImage,
                          );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جارٍ إضافة الوجبة...')),
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

  /// 3) Dialog to EDIT an existing dish
  Future<void> _showEditDishDialog(
    BuildContext context,
    WidgetRef ref,
    String sectionId,
    Dish dish,
    String vendorId,
  ) async {
    final _nameCtl = TextEditingController(text: dish.name);
    final _priceCtl = TextEditingController(text: dish.price.toString());
    File? _newImage;

    Future<File?> _pickNewImage() async {
      final picked = await showModalBottomSheet<File?>(
        context: context,
        builder: (ctx) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('تغيير الصورة'),
                  onTap: () async {
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 75,
                    );
                    Navigator.of(
                      ctx,
                    ).pop(file == null ? null : File(file.path));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('التقاط صورة جديدة'),
                  onTap: () async {
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 75,
                    );
                    Navigator.of(
                      ctx,
                    ).pop(file == null ? null : File(file.path));
                  },
                ),
              ],
            ),
          );
        },
      );
      return picked;
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('تعديل الوجبة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show existing image if there is one
                    if (dish.imageUrl != null && _newImage == null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          dish.imageUrl!,
                          width: 120,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) {
                            return const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // If user picked a new image, preview that instead
                    if (_newImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          _newImage!,
                          width: 120,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('استبدال الصورة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final picked = await _pickNewImage();
                        if (picked != null) {
                          setState(() {
                            _newImage = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtl,
                      decoration: const InputDecoration(
                        labelText: 'اسم الوجبة',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceCtl,
                      decoration: const InputDecoration(
                        labelText: 'السعر (ش.إ)',
                      ),
                      keyboardType: TextInputType.number,
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
                    final newName = _nameCtl.text.trim();
                    final newPriceText = _priceCtl.text.trim();
                    if (newName.isNotEmpty && newPriceText.isNotEmpty) {
                      ref
                          .read(restaurantMenuProvider(vendorId).notifier)
                          .updateDish(
                            sectionId: sectionId,
                            dishId: dish.id,
                            newName: newName,
                            newPrice: newPriceText,
                            newImage: _newImage,
                          );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جارٍ تحديث الوجبة...')),
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
