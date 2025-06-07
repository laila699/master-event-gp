// lib/manage_distribution_store_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// تعريف كلاس لمساعدة في إدارة حقول التوزيعات المحددة
class SpecificDistributionController {
  TextEditingController nameController;
  TextEditingController imageController;
  TextEditingController priceController;
  TextEditingController componentsController;
  List<TextEditingController> suitableForControllers;
  bool isCustomizable;

  SpecificDistributionController({
    String? name,
    String? image,
    String? price,
    String? components,
    List<String>? suitableFor,
    bool? isCustomizable,
  })  : nameController = TextEditingController(text: name ?? ''),
        imageController = TextEditingController(text: image ?? ''),
        priceController = TextEditingController(text: price ?? ''),
        componentsController = TextEditingController(text: components ?? ''),
        suitableForControllers = suitableFor != null
            ? suitableFor.map((e) => TextEditingController(text: e)).toList()
            : [TextEditingController()],
        isCustomizable = isCustomizable ?? false;

  void dispose() {
    nameController.dispose();
    imageController.dispose();
    priceController.dispose();
    componentsController.dispose();
    for (var c in suitableForControllers) {
      c.dispose();
    }
  }

  // لتحويل البيانات إلى Map لإرسالها للباك إند (مثال)
  Map<String, dynamic> toMap() {
    return {
      'name': nameController.text,
      'image': imageController.text,
      'price': priceController.text,
      'components': componentsController.text,
      'suitable_for': suitableForControllers
          .where((c) => c.text.isNotEmpty)
          .map((c) => c.text)
          .toList(),
      'is_customizable': isCustomizable,
    };
  }
}

class ManageDistributionStoreScreen extends StatefulWidget {
  final Map<String, dynamic>? distributionStore; // المتجر المراد تعديله (اختياري)

  const ManageDistributionStoreScreen({super.key, this.distributionStore});

  @override
  State<ManageDistributionStoreScreen> createState() =>
      _ManageDistributionStoreScreenState();
}

class _ManageDistributionStoreScreenState
    extends State<ManageDistributionStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _mainImageController;
  late TextEditingController _priceRangeController;
  late bool _deliveryAvailable;
  late TextEditingController _aboutController;

  final List<TextEditingController> _galleryImageControllers = [];
  final List<TextEditingController> _eventTypesCoveredControllers = [];
  final List<TextEditingController> _distributionTypesOfferedControllers = [];
  final List<SpecificDistributionController> _specificDistributions = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.distributionStore?['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.distributionStore?['description'] ?? '');
    _mainImageController = TextEditingController(text: widget.distributionStore?['main_image'] ?? '');
    _priceRangeController = TextEditingController(text: widget.distributionStore?['price_range'] ?? '');
    _deliveryAvailable = widget.distributionStore?['delivery_available'] ?? false;
    _aboutController = TextEditingController(text: widget.distributionStore?['details']?['about'] ?? '');

    // تعبئة حقول الصور الإضافية (Gallery Images)
    if (widget.distributionStore != null && widget.distributionStore!['details']?['gallery_images'] != null) {
      for (var img in widget.distributionStore!['details']['gallery_images']) {
        _galleryImageControllers.add(TextEditingController(text: img));
      }
    } else {
      _galleryImageControllers.add(TextEditingController()); // حقل واحد فارغ على الأقل
    }

    // تعبئة حقول أنواع المناسبات
    if (widget.distributionStore != null && widget.distributionStore!['event_types_covered'] != null) {
      for (var type in widget.distributionStore!['event_types_covered']) {
        _eventTypesCoveredControllers.add(TextEditingController(text: type));
      }
    } else {
      _eventTypesCoveredControllers.add(TextEditingController());
    }

    // تعبئة حقول أنواع التوزيعات المقدمة
    if (widget.distributionStore != null && widget.distributionStore!['distribution_types_offered'] != null) {
      for (var type in widget.distributionStore!['distribution_types_offered']) {
        _distributionTypesOfferedControllers.add(TextEditingController(text: type));
      }
    } else {
      _distributionTypesOfferedControllers.add(TextEditingController());
    }

    // تعبئة حقول التوزيعات المحددة (Specific Distributions)
    if (widget.distributionStore != null && widget.distributionStore!['details']?['specific_distributions'] != null) {
      for (var dist in widget.distributionStore!['details']['specific_distributions']) {
        _specificDistributions.add(SpecificDistributionController(
          name: dist['name'],
          image: dist['image'],
          price: dist['price'],
          components: dist['components'],
          suitableFor: List<String>.from(dist['suitable_for'] ?? []),
          isCustomizable: dist['is_customizable'],
        ));
      }
    } else {
      _specificDistributions.add(SpecificDistributionController()); // إضافة توزيعة واحدة فارغة على الأقل
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mainImageController.dispose();
    _priceRangeController.dispose();
    _aboutController.dispose();
    for (var c in _galleryImageControllers) c.dispose();
    for (var c in _eventTypesCoveredControllers) c.dispose();
    for (var c in _distributionTypesOfferedControllers) c.dispose();
    for (var c in _specificDistributions) c.dispose();
    super.dispose();
  }

  // دوال مساعدة لإضافة/إزالة حقول ديناميكية
  void _addTextField(List<TextEditingController> controllers) {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void _removeTextField(List<TextEditingController> controllers, int index) {
    setState(() {
      controllers[index].dispose();
      controllers.removeAt(index);
    });
  }

  void _addSpecificDistribution() {
    setState(() {
      _specificDistributions.add(SpecificDistributionController());
    });
  }

  void _removeSpecificDistribution(int index) {
    setState(() {
      _specificDistributions[index].dispose();
      _specificDistributions.removeAt(index);
    });
  }

  void _saveDistributionStore() {
    if (_formKey.currentState!.validate()) {
      // هنا سيتم إرسال البيانات إلى الـ Backend
      final newStoreData = {
        'id': widget.distributionStore?['id'] ?? UniqueKey().toString(), // افتراضي لـ ID
        'name': _nameController.text,
        'description': _descriptionController.text,
        'main_image': _mainImageController.text,
        'price_range': _priceRangeController.text,
        'delivery_available': _deliveryAvailable,
        'event_types_covered': _eventTypesCoveredControllers
            .where((c) => c.text.isNotEmpty)
            .map((c) => c.text)
            .toList(),
        'distribution_types_offered': _distributionTypesOfferedControllers
            .where((c) => c.text.isNotEmpty)
            .map((c) => c.text)
            .toList(),
        'overall_rating': widget.distributionStore?['overall_rating'] ?? 0.0, // تقييم افتراضي
        'details': {
          'about': _aboutController.text,
          'gallery_images': _galleryImageControllers
              .where((c) => c.text.isNotEmpty)
              .map((c) => c.text)
              .toList(),
          'specific_distributions': _specificDistributions
              .where((s) => s.nameController.text.isNotEmpty) // فقط التوزيعات التي لها اسم
              .map((s) => s.toMap())
              .toList(),
          'customer_reviews': widget.distributionStore?['details']?['customer_reviews'] ?? [], // مراجعات افتراضية
        },
      };

      print('Distribution Store Data to Save: $newStoreData');

      // في التطبيق الحقيقي: استدعاء API للحفظ
      Navigator.pop(context, true); // إرجاع true للإشارة إلى أن البيانات قد تتغير
    }
  }

  void _deleteDistributionStore() {
    // في التطبيق الحقيقي: استدعاء API للحذف
    print('Deleting distribution store: ${widget.distributionStore?['name']}');
    Navigator.pop(context, true); // إرجاع true للإشارة إلى أن البيانات قد تتغير
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.distributionStore != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'تعديل بيانات متجر التوزيعات' : 'إضافة متجر توزيعات جديد',
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('تأكيد الحذف', style: GoogleFonts.cairo()),
                    content: Text(
                        'هل أنت متأكد من رغبتك في حذف متجر التوزيعات هذا؟',
                        style: GoogleFonts.cairo()),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('إلغاء', style: GoogleFonts.cairo()),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _deleteDistributionStore();
                        },
                        child: Text('حذف',
                            style: GoogleFonts.cairo(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'اسم متجر التوزيعات',
                hint: 'مثال: لمسة فنية للتوزيعات',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المتجر';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'وصف قصير للمتجر',
                hint: 'نصمم توزيعات فريدة لكل مناسبة...',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف المتجر';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _mainImageController,
                label: 'رابط الصورة الرئيسية للمتجر',
                hint: 'assets/main_store_image.jpg',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رابط الصورة الرئيسية';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _priceRangeController,
                label: 'نطاق الأسعار',
                hint: 'مثال: تبدأ من 7 شيكل',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال نطاق الأسعار';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Text(
                    'توصيل متاح:',
                    style: GoogleFonts.cairo(
                        fontSize: 16, color: Colors.black87),
                  ),
                  Checkbox(
                    value: _deliveryAvailable,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _deliveryAvailable = newValue!;
                      });
                    },
                    activeColor: Colors.deepPurple,
                  ),
                ],
              ),
              _buildTextField(
                controller: _aboutController,
                label: 'نبذة عن المتجر (تفاصيل)',
                hint: 'نحن في "لمسة فنية" نؤمن بأن...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // صور المعرض (Gallery Images)
              _buildDynamicTextFieldsSection(
                label: 'صور المعرض (معرض التوزيعات):',
                hint: 'assets/gallery_image.jpg',
                controllers: _galleryImageControllers,
                onAdd: () => _addTextField(_galleryImageControllers),
                onRemove: (index) => _removeTextField(_galleryImageControllers, index),
              ),
              const SizedBox(height: 20),

              // أنواع المناسبات التي يغطيها المتجر
              _buildDynamicTextFieldsSection(
                label: 'أنواع المناسبات التي يغطيها المتجر:',
                hint: 'مثال: زفاف، خطوبة، مواليد',
                controllers: _eventTypesCoveredControllers,
                onAdd: () => _addTextField(_eventTypesCoveredControllers),
                onRemove: (index) => _removeTextField(_eventTypesCoveredControllers, index),
              ),
              const SizedBox(height: 20),

              // أنواع التوزيعات المقدمة
              _buildDynamicTextFieldsSection(
                label: 'أنواع التوزيعات المقدمة:',
                hint: 'مثال: شوكولاتة مغلفة، شموع',
                controllers: _distributionTypesOfferedControllers,
                onAdd: () => _addTextField(_distributionTypesOfferedControllers),
                onRemove: (index) => _removeTextField(_distributionTypesOfferedControllers, index),
              ),
              const SizedBox(height: 20),

              // التوزيعات المحددة (specific_distributions)
              Text(
                'التوزيعات المحددة (منتجات المتجر):',
                style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _specificDistributions.length,
                itemBuilder: (context, index) {
                  final distController = _specificDistributions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'توزيعة #${index + 1}',
                                style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange),
                              ),
                              if (_specificDistributions.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_forever,
                                      color: Colors.red),
                                  onPressed: () => _removeSpecificDistribution(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: distController.nameController,
                            label: 'اسم التوزيعة',
                            hint: 'مثال: توزيعة شوكولاتة الزفاف',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال اسم التوزيعة';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: distController.imageController,
                            label: 'صورة التوزيعة',
                            hint: 'assets/distribution_item.jpg',
                          ),
                          _buildTextField(
                            controller: distController.priceController,
                            label: 'سعر التوزيعة',
                            hint: 'مثال: 8 شيكل/حبة',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال سعر التوزيعة';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: distController.componentsController,
                            label: 'مكونات التوزيعة',
                            hint: 'مثال: شوكولاتة بلجيكية، تغليف حريري',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),
                          // أنواع المناسبات المناسبة لهذه التوزيعة
                          Text(
                            'مناسبة لـ (لهذه التوزيعة):',
                            style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700]),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: distController.suitableForControllers.length,
                            itemBuilder: (context, suitableIndex) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: distController
                                          .suitableForControllers[suitableIndex],
                                      label: 'مناسبة #${suitableIndex + 1}',
                                      hint: 'مثال: زفاف',
                                    ),
                                  ),
                                  if (distController.suitableForControllers.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          distController
                                              .suitableForControllers[suitableIndex]
                                              .dispose();
                                          distController.suitableForControllers
                                              .removeAt(suitableIndex);
                                        });
                                      },
                                    ),
                                ],
                              );
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  distController.suitableForControllers
                                      .add(TextEditingController());
                                });
                              },
                              icon: const Icon(Icons.add, color: Colors.blueAccent),
                              label: Text('أضف مناسبة أخرى',
                                  style:
                                      GoogleFonts.cairo(color: Colors.blueAccent)),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'قابلة للتخصيص:',
                                style: GoogleFonts.cairo(
                                    fontSize: 16, color: Colors.black87),
                              ),
                              Checkbox(
                                value: distController.isCustomizable,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    distController.isCustomizable = newValue!;
                                  });
                                },
                                activeColor: Colors.deepPurple,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: TextButton.icon(
                  onPressed: _addSpecificDistribution,
                  icon: const Icon(Icons.add_box, color: Colors.deepPurple),
                  label: Text('أضف توزيعة جديدة',
                      style: GoogleFonts.cairo(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveDistributionStore,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    isEditing ? 'حفظ التعديلات' : 'إضافة المتجر',
                    style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء حقول النصوص
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.cairo(color: Colors.deepPurple),
          hintStyle: GoogleFonts.cairo(color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  // دالة مساعدة لبناء أقسام الحقول الديناميكية العامة (صور المعرض، أنواع المناسبات، أنواع التوزيعات)
  Widget _buildDynamicTextFieldsSection({
    required String label,
    required String hint,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: controllers[index],
                      label: '$label ${index + 1}',
                      hint: hint,
                    ),
                  ),
                  if (controllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => onRemove(index),
                    ),
                ],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.deepPurple),
            label: Text('أضف ${label.replaceAll(':', '')} أخرى',
                style: GoogleFonts.cairo(color: Colors.deepPurple)),
          ),
        ),
      ],
    );
  }
}