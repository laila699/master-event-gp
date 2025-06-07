// lib/manage_photographer_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagePhotographerScreen extends StatefulWidget {
  final Map<String, dynamic>? photographer; // المصور المراد تعديله (اختياري)

  const ManagePhotographerScreen({super.key, this.photographer});

  @override
  State<ManagePhotographerScreen> createState() =>
      _ManagePhotographerScreenState();
}

class _ManagePhotographerScreenState extends State<ManagePhotographerScreen> {
  final _formKey = GlobalKey<FormState>(); // مفتاح للتحقق من صحة المدخلات
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _priceRangeController;
  late bool _isMobilePhotographer; // للمصور المتنقل

  final List<TextEditingController> _portfolioImageControllers = []; // لصور البورتفوليو
  final List<TextEditingController> _photographyTypeControllers = []; // لأنواع التصوير
  final List<TextEditingController> _eventTypeControllers = []; // لأنواع المناسبات

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.photographer?['name'] ?? '');
    _cityController = TextEditingController(text: widget.photographer?['city'] ?? '');
    _phoneController = TextEditingController(text: widget.photographer?['phone'] ?? '');
    _priceRangeController = TextEditingController(text: widget.photographer?['priceRange'] ?? '');
    _isMobilePhotographer = widget.photographer?['mobile'] ?? false;

    // تعبئة حقول صور البورتفوليو
    if (widget.photographer != null && widget.photographer!['portfolioImages'] != null) {
      for (var img in widget.photographer!['portfolioImages']) {
        _portfolioImageControllers.add(TextEditingController(text: img));
      }
    } else {
      _portfolioImageControllers.add(TextEditingController()); // حقل واحد فارغ على الأقل
    }

    // تعبئة حقول أنواع التصوير
    if (widget.photographer != null && widget.photographer!['photographyTypes'] != null) {
      for (var type in widget.photographer!['photographyTypes']) {
        _photographyTypeControllers.add(TextEditingController(text: type));
      }
    } else {
      _photographyTypeControllers.add(TextEditingController()); // حقل واحد فارغ على الأقل
    }

    // تعبئة حقول أنواع المناسبات
    if (widget.photographer != null && widget.photographer!['eventTypes'] != null) {
      for (var event in widget.photographer!['eventTypes']) {
        _eventTypeControllers.add(TextEditingController(text: event));
      }
    } else {
      _eventTypeControllers.add(TextEditingController()); // حقل واحد فارغ على الأقل
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _priceRangeController.dispose();
    for (var controller in _portfolioImageControllers) {
      controller.dispose();
    }
    for (var controller in _photographyTypeControllers) {
      controller.dispose();
    }
    for (var controller in _eventTypeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // دوال لإضافة/إزالة حقول ديناميكية
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

  void _savePhotographer() {
    if (_formKey.currentState!.validate()) {
      // هنا سيتم إرسال البيانات إلى الـ Backend
      // (مثال فقط - لن يقوم بحفظها فعلياً في هذا الكود)
      final newPhotographerData = {
        'name': _nameController.text,
        'city': _cityController.text,
        'mobile': _isMobilePhotographer,
        'phone': _phoneController.text,
        'priceRange': _priceRangeController.text,
        'portfolioImages': _portfolioImageControllers
            .where((c) => c.text.isNotEmpty)
            .map((c) => c.text)
            .toList(),
        'photographyTypes': _photographyTypeControllers
            .where((c) => c.text.isNotEmpty)
            .map((c) => c.text)
            .toList(),
        'eventTypes': _eventTypeControllers
            .where((c) => c.text.isNotEmpty)
            .map((c) => c.text)
            .toList(),
        'rating': widget.photographer?['rating'] ?? 0.0, // تقييم افتراضي أو الحالي
        'customerReviews': widget.photographer?['customerReviews'] ?? [], // مراجعات افتراضية أو الحالية
      };

      print('Photographer Data to Save: $newPhotographerData'); // للتحقق في الـ Console

      // في التطبيق الحقيقي، هنا تقومين باستدعاء API لحفظ البيانات
      // وبعد نجاح الحفظ، ترجعين إلى الشاشة السابقة
      Navigator.pop(context, true); // إرجاع true للإشارة إلى أن البيانات قد تتغير
    }
  }

  void _deletePhotographer() {
    // في التطبيق الحقيقي، هنا يتم إرسال طلب حذف إلى الـ Backend
    print('Deleting photographer: ${widget.photographer?['name']}');
    // بعد نجاح الحذف، ترجعين إلى الشاشة السابقة
    Navigator.pop(context, true); // إرجاع true للإشارة إلى أن البيانات قد تتغير
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.photographer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'تعديل بيانات المصور' : 'إضافة مصور جديد',
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          if (isEditing) // زر الحذف يظهر فقط في وضع التعديل
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                // تأكيد الحذف
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('تأكيد الحذف', style: GoogleFonts.cairo()),
                    content: Text('هل أنت متأكد من رغبتك في حذف هذا المصور؟',
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
                          _deletePhotographer(); // استدعاء دالة الحذف
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
                label: 'اسم المصور',
                hint: 'أدخل اسم المصور كاملاً',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المصور';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _cityController,
                label: 'المدينة',
                hint: 'مثال: نابلس، الخليل',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المدينة';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: 'مثال: 0599123456',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _priceRangeController,
                label: 'نطاق السعر',
                hint: 'مثال: يبدأ من 150 شيكل، حسب الباقة',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال نطاق السعر';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Text(
                    'مصور متنقل (يزور الأماكن):',
                    style: GoogleFonts.cairo(
                        fontSize: 16, color: Colors.black87),
                  ),
                  Checkbox(
                    value: _isMobilePhotographer,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isMobilePhotographer = newValue!;
                      });
                    },
                    activeColor: Colors.deepPurple,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildDynamicTextFieldsSection(
                label: 'صور البورتفوليو:',
                hint: 'assets/image_name.jpg',
                controllers: _portfolioImageControllers,
                onAdd: () => _addTextField(_portfolioImageControllers),
                onRemove: (index) => _removeTextField(_portfolioImageControllers, index),
              ),
              const SizedBox(height: 20),

              _buildDynamicTextFieldsSection(
                label: 'أنواع التصوير:',
                hint: 'مثال: كلاسيكي، سينمائي، استوديو',
                controllers: _photographyTypeControllers,
                onAdd: () => _addTextField(_photographyTypeControllers),
                onRemove: (index) => _removeTextField(_photographyTypeControllers, index),
              ),
              const SizedBox(height: 20),

              _buildDynamicTextFieldsSection(
                label: 'أنواع المناسبات:',
                hint: 'مثال: زفاف، خطوبة، تخرج',
                controllers: _eventTypeControllers,
                onAdd: () => _addTextField(_eventTypeControllers),
                onRemove: (index) => _removeTextField(_eventTypeControllers, index),
              ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _savePhotographer,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    isEditing ? 'حفظ التعديلات' : 'إضافة المصور',
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
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

  // دالة مساعدة لبناء أقسام الحقول الديناميكية (صور، أنواع تصوير، مناسبات)
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
                  if (controllers.length > 1) // لا تعرض زر الحذف إذا كان هناك حقل واحد فقط
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