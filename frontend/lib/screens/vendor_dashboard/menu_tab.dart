// lib/screens/vendor_dashboard/menu_tab.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/menu_section.dart';

import '../../providers/restaurant_provider.dart';

class MenuTab extends ConsumerWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(restaurantMenuProvider);
    final host = '172.16.0.120';
    // On iOS Simulator, localhost will work; on Android emulator you must use 10.0.2.2
    final base = 'http://$host:5000/api';

    return menuAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('خطأ: $err')),
      data: (sections) {
        return Stack(
          children: [
            // Main content: list of expandable sections
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: sections.length,
              itemBuilder: (context, secIndex) {
                final section = sections[secIndex];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ExpansionTile(
                    key: ValueKey(section.id),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      section.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // 1) List of dishes under this section
                      ...section.items.map((dish) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
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
                                      '${base}${dish.imageUrl}',
                                      width: 40,
                                      height: 40,
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
                          title: Text(
                            dish.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${dish.price} شيكل',
                            style: TextStyle(color: Colors.deepPurple.shade600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit dish
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: () {
                                  _showEditDishDialog(
                                    context,
                                    ref,
                                    section.id,
                                    dish,
                                  );
                                },
                              ),
                              // Delete dish
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  ref
                                      .read(restaurantMenuProvider.notifier)
                                      .deleteDish(
                                        sectionId: section.id,
                                        dishId: dish.id,
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('جارٍ حذف الوجبة'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // 2) “Add Dish” button at bottom of this section
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة وجبة جديدة'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            _showAddDishDialog(context, ref, section.id);
                          },
                        ),
                      ),

                      const Divider(height: 1),
                    ],
                  ),
                );
              },
            ),

            // FAB for adding a new section (only)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.add_business),
                onPressed: () {
                  _showAddSectionDialog(context, ref);
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
      ref.read(restaurantMenuProvider.notifier).addSection(name: sectionName);
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
                        backgroundColor: Colors.deepPurple.shade200,
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
                        labelText: 'السعر (ر.س)',
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
                          .read(restaurantMenuProvider.notifier)
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
                        backgroundColor: Colors.deepPurple.shade200,
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
                        labelText: 'السعر (ر.س)',
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
                          .read(restaurantMenuProvider.notifier)
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
