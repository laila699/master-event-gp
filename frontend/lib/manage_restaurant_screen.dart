// lib/manage_restaurant_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageRestaurantScreen extends StatefulWidget {
  final Map<String, dynamic>? restaurant; // المطعم المراد تعديله (اختياري)

  const ManageRestaurantScreen({super.key, this.restaurant});

  @override
  State<ManageRestaurantScreen> createState() => _ManageRestaurantScreenState();
}

class _ManageRestaurantScreenState extends State<ManageRestaurantScreen> {
  final _formKey = GlobalKey<FormState>(); // مفتاح للتحقق من صحة المدخلات
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _imageUrlController; // للصورة الرئيسية
  final List<TextEditingController> _foodImageControllers = []; // لصور الأطعمة

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.restaurant?['name'] ?? '');
    _locationController = TextEditingController(text: widget.restaurant?['location'] ?? '');
    _phoneController = TextEditingController(text: widget.restaurant?['phone'] ?? '');
    _cityController = TextEditingController(text: widget.restaurant?['city'] ?? '');
    _imageUrlController = TextEditingController(text: widget.restaurant?['image'] ?? '');

    // تعبئة حقول صور الطعام إذا كان المطعم موجوداً
    if (widget.restaurant != null && widget.restaurant!['foodImages'] != null) {
      for (var img in widget.restaurant!['foodImages']) {
        _foodImageControllers.add(TextEditingController(text: img));
      }
    } else {
      _foodImageControllers.add(TextEditingController()); // حقل واحد فارغ على الأقل
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _imageUrlController.dispose();
    for (var controller in _foodImageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addFoodImageField() {
    setState(() {
      _foodImageControllers.add(TextEditingController());
    });
  }

  void _removeFoodImageField(int index) {
    setState(() {
      _foodImageControllers[index].dispose();
      _foodImageControllers.removeAt(index);
    });
  }

  void _saveRestaurant() {
    if (_formKey.currentState!.validate()) {
      // هنا سيتم إرسال البيانات إلى الـ Backend
      // (مثال فقط - لن يقوم بحفظها فعلياً في هذا الكود)
      final newRestaurantData = {
        'name': _nameController.text,
        'location': _locationController.text,
        'phone': _phoneController.text,
        'city': _cityController.text,
        'image': _imageUrlController.text,
        'foodImages': _foodImageControllers
            .where((c) => c.text.isNotEmpty)
            .map((c) => c.text)
            .toList(),
        'rating': widget.restaurant?['rating'] ?? 0.0, // تقييم افتراضي أو الحالي
        'customerReviews': widget.restaurant?['customerReviews'] ?? [], // مراجعات افتراضية أو الحالية
      };

      print('Restaurant Data to Save: $newRestaurantData'); // للتحقق في الـ Console

      // في التطبيق الحقيقي، هنا تقومين باستدعاء API لحفظ البيانات
      // وبعد نجاح الحفظ، ترجعين إلى الشاشة السابقة
      Navigator.pop(context, true); // إرجاع true للإشارة إلى أن البيانات قد تتغير
    }
  }

  void _deleteRestaurant() {
    // في التطبيق الحقيقي، هنا يتم إرسال طلب حذف إلى الـ Backend
    print('Deleting restaurant: ${widget.restaurant?['name']}');
    // بعد نجاح الحذف، ترجعين إلى الشاشة السابقة
    Navigator.pop(context, true); // إرجاع true للإشارة إلى أن البيانات قد تتغير
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.restaurant != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'تعديل بيانات المطعم' : 'إضافة مطعم جديد',
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
                    content: Text('هل أنت متأكد من رغبتك في حذف هذا المطعم؟',
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
                          _deleteRestaurant(); // استدعاء دالة الحذف
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
                label: 'اسم المطعم',
                hint: 'أدخل اسم المطعم كاملاً',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المطعم';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _locationController,
                label: 'الموقع التفصيلي',
                hint: 'مثال: رفيديا - شارع الجامعة',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الموقع';
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
                controller: _imageUrlController,
                label: 'رابط الصورة الرئيسية',
                hint: 'assets/your_main_image.jpg',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رابط الصورة الرئيسية';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'صور الأطعمة/القاعة:',
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(height: 10),
              // حقول صور الأطعمة/القاعة
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _foodImageControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _foodImageControllers[index],
                            label: 'صورة ${index + 1}',
                            hint: 'assets/food_image_${index + 1}.jpg',
                          ),
                        ),
                        if (_foodImageControllers.length > 1) // لا تعرض زر الحذف إذا كان هناك حقل واحد فقط
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () => _removeFoodImageField(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addFoodImageField,
                  icon: const Icon(Icons.add_a_photo, color: Colors.deepPurple),
                  label: Text('أضف صورة أخرى',
                      style: GoogleFonts.cairo(color: Colors.deepPurple)),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveRestaurant,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    isEditing ? 'حفظ التعديلات' : 'إضافة المطعم',
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
}