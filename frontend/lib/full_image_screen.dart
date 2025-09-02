import 'package:flutter/material.dart';

class FullImageScreen extends StatelessWidget {
  final String imagePath;

  const FullImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية سوداء للشاشة
      appBar: AppBar(
        backgroundColor: Colors.black, // خلفية AppBar سوداء
        iconTheme: const IconThemeData(color: Colors.white), // لون أيقونات الـ AppBar (مثل زر الرجوع) أبيض
        elevation: 0, // إزالة الظل من AppBar
      ),
      body: Center(
        child: InteractiveViewer( // <== هذا الويدجت اللي بيسمح بالزوم والتحريك
          clipBehavior: Clip.none, // مهم عشان الزوم ما يقص أطراف الصورة
          minScale: 0.1, // أقل نسبة تصغير (10% من الحجم الأصلي)
          maxScale: 4.0, // أقصى نسبة تكبير (400% من الحجم الأصلي)
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain, // يجعل الصورة تظهر كاملة داخل المساحة المتاحة، مع الحفاظ على أبعادها
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.broken_image_outlined, size: 100, color: Colors.white));
            },
          ),
        ),
      ),
    );
  }
}