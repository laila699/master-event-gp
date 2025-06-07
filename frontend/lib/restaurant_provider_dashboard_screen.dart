// lib/restaurant_provider_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_restaurant_screen.dart';

// **ملاحظة:** في التطبيق الحقيقي، هذه القائمة ستأتي من الـ Backend
// لكن لأغراض الـ Front-end، سنستخدم هذه البيانات كمثال
final List<Map<String, dynamic>> myRestaurants = [
  {
    'name': 'fareed zamano',
    'image': 'assets/fareed.jpg',
    'rating': 4.7,
    'location': 'رفيديا - نابلس',
    'phone': '0593130136',
    'foodImages': ['assets/f1.jpg', 'assets/f2.jpg'],
    'city': 'نابلس',
    'customerReviews': [
      {'name': 'أحمد', 'rating': 5, 'comment': 'طعام ممتاز وخدمة رائعة!'},
      {
        'name': 'ليلى',
        'rating': 4,
        'comment': 'الجو جميل لكن الأسعار مرتفعة قليلاً.',
      },
    ],
  },
  {
    'name': '1948',
    'image': 'assets/1948.jpg',
    'rating': 4.5,
    'location': 'رفيديا - نابلس',
    'phone': '0597888807',
    'foodImages': ['assets/jeb.jpg', 'assets/ma.jpg', 'assets/kob.jpg'],
    'city': 'نابلس',
    'customerReviews': [
      {'name': 'سعيد', 'rating': 4, 'comment': 'الطعام شهي والمكان نظيف.'},
    ],
  },
  {
    'name': 'مطعم القدس',
    'image': 'assets/f1.jpg',
    'rating': 4.2,
    'location': 'شارع القدس - الخليل',
    'phone': '0599XXXXXX',
    'foodImages': ['assets/jeb.jpg', 'assets/kob.jpg'],
    'city': 'الخليل',
    'customerReviews': [
      {'name': 'منى', 'rating': 5, 'comment': 'أفضل بوفيه حضرته على الإطلاق!'},
    ],
  },
  {
    'name': 'مطعم حلا',
    'image': 'assets/f2.jpg',
    'rating': 4.2,
    'location': 'شارع القدس - الخليل',
    'phone': '0599XXXXXX',
    'foodImages': ['assets/kob.jpg', 'assets/jeb.jpg'],
    'city': 'طولكرم',
    'customerReviews': [
      {'name': 'منى', 'rating': 5, 'comment': 'أفضل بوفيه حضرته على الإطلاق!'},
    ],
  },
];

class RestaurantProviderDashboardScreen extends StatefulWidget {
  const RestaurantProviderDashboardScreen({super.key});

  @override
  State<RestaurantProviderDashboardScreen> createState() =>
      _RestaurantProviderDashboardScreenState();
}

class _RestaurantProviderDashboardScreenState
    extends State<RestaurantProviderDashboardScreen> {
  // هذه الدالة ستُستخدم لتحديث القائمة بعد إضافة/تعديل المطاعم
  void _refreshRestaurants() {
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
          'لوحة تحكم المطاعم',
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
          myRestaurants
                  .isEmpty // عرض رسالة إذا لم يكن هناك مطاعم
              ? Center(
                child: Text(
                  'لم يتم إضافة أي مطعم بعد. اضغط على الزر "+" لإضافة مطعمك الأول.',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: myRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = myRestaurants[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () async {
                        // عند الضغط على المطعم، ننتقل لصفحة الإدارة للتعديل
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ManageRestaurantScreen(
                                  restaurant:
                                      restaurant, // نرسل بيانات المطعم الحالي
                                ),
                          ),
                        );
                        // بعد العودة من صفحة الإدارة (سواء تم تعديل أو حذف)، نقوم بتحديث القائمة
                        _refreshRestaurants();
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
                                restaurant['image'],
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
                                    restaurant['name'],
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
                                        '${restaurant['rating']}',
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
                                          restaurant['location'],
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
                                    '📞 ${restaurant['phone']}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      color: Colors.blue,
                                    ),
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
              builder: (context) => const ManageRestaurantScreen(),
            ),
          );
          // بعد العودة من صفحة الإضافة، نقوم بتحديث القائمة
          _refreshRestaurants();
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
