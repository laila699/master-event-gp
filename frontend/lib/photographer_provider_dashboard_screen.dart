// lib/photographer_provider_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/manage_photographer_screen.dart';

final List<Map<String, dynamic>> myPhotographers = [
  {
    'name': 'Mohammad Samman',
    'city': 'نابلس',
    'mobile': true,
    'portfolioImages': <String>['assets/p1.jpg', 'assets/p2.jpg'],
    'rating': 4.7,
    'phone': '0599123456',
    'photographyTypes': ['كلاسيكي', 'سينمائي'],
    'eventTypes': ['زفاف', 'خطوبة'],
    'priceRange': 'يبدأ من 150 شيكل',
    'customerReviews': [4.9, 4.5, 5.0],
  },
  {
    'name': 'Sara Yaseen',
    'city': 'طولكرم',
    'mobile': false,
    'portfolioImages': <String>['assets/s1.jpg', 'assets/s2.jpg'],
    'rating': 4.5,
    'phone': '0599876543',
    'photographyTypes': ['استوديو'],
    'eventTypes': ['تخرج', 'أطفال'],
    'priceRange': 'حسب المدة',
    'customerReviews': [4.2, 4.8],
  },
  {
    'name': 'Ahmad Khalil',
    'city': 'نابلس',
    'mobile': true,
    'portfolioImages': <String>['assets/p1.jpg'],
    'rating': 4.9,
    'phone': '0591112233',
    'photographyTypes': ['تصوير خارجي'],
    'eventTypes': ['عيد ميلاد', 'افتتاح مشروع'],
    'priceRange': 'يبدأ من 100 شيكل',
    'customerReviews': [5.0, 4.8, 4.9],
  },
  {
    'name': 'Lina Omar',
    'city': 'الخليل',
    'mobile': true,
    'portfolioImages': <String>['assets/p1.jpg', 'assets/p2.jpg'],
    'rating': 4.6,
    'phone': '0595556677',
    'photographyTypes': ['كلاسيكي', 'استوديو'],
    'eventTypes': ['زفاف', 'كتب كتاب'],
    'priceRange': 'حسب الباقة',
    'customerReviews': [4.5, 4.7],
  },
];

class PhotographerProviderDashboardScreen extends StatefulWidget {
  const PhotographerProviderDashboardScreen({super.key});

  @override
  State<PhotographerProviderDashboardScreen> createState() =>
      _PhotographerProviderDashboardScreenState();
}

class _PhotographerProviderDashboardScreenState
    extends State<PhotographerProviderDashboardScreen> {
  // هذه الدالة ستُستخدم لتحديث القائمة بعد إضافة/تعديل المصورين
  void _refreshPhotographers() {
    // في التطبيق الحقيقي، هنا يتم استدعاء الـ Backend لجلب البيانات المحدثة
    // حالياً، لا نفعل شيئاً لأن البيانات ثابتة (Hardcoded)
    setState(() {
      // فقط لتشغيل إعادة بناء الواجهة إذا تغيرت البيانات (في المستقبل)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم المصورين',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body:
          myPhotographers
                  .isEmpty // عرض رسالة إذا لم يكن هناك مصورون
              ? Center(
                child: Text(
                  'لم يتم إضافة أي مصور بعد. اضغط على الزر "+" لإضافة مصورك الأول.',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: myPhotographers.length,
                itemBuilder: (context, index) {
                  final photographer = myPhotographers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () async {
                        // عند الضغط على المصور، ننتقل لصفحة الإدارة للتعديل
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ManagePhotographerScreen(
                                  photographer:
                                      photographer, // نرسل بيانات المصور الحالي
                                ),
                          ),
                        );
                        // بعد العودة من صفحة الإدارة (سواء تم تعديل أو حذف)، نقوم بتحديث القائمة
                        _refreshPhotographers();
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                photographer['portfolioImages'][0], // عرض أول صورة من البورتفوليو
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    photographer['name'],
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      Text(
                                        '${photographer['rating']}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 15,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      Expanded(
                                        child: Text(
                                          photographer['city'],
                                          style: GoogleFonts.cairo(
                                            fontSize: 15,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '📞 ${photographer['phone']}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 4.0,
                                    children:
                                        (photographer['photographyTypes']
                                                as List<String>)
                                            .map(
                                              (type) => Chip(
                                                label: Text(
                                                  type,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Colors.blue.shade50,
                                                labelStyle: GoogleFonts.cairo(
                                                  color: Colors.blue.shade700,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 0,
                                                    ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // عند الضغط على زر الإضافة، ننتقل لصفحة الإدارة بدون بيانات (لإضافة جديد)
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManagePhotographerScreen(),
            ),
          );
          // بعد العودة من صفحة الإضافة، نقوم بتحديث القائمة
          _refreshPhotographers();
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
