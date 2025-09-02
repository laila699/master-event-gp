import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'feedbackScreen.dart';
import 'full_image_screen.dart';
import 'BookingScreen.dart';

class ToolsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> store;

  const ToolsDetailScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final List<String> galleryImages =
        (store['details']?['gallery_images'] as List<String>?) ??
        [store['main_image']];
    final List<Map<String, dynamic>> specificDistributions =
        (store['details']?['specific_distributions']
            as List<Map<String, dynamic>>?) ??
        [];
    final List<Map<String, dynamic>> customerReviews =
        (store['details']?['customer_reviews']
            as List<Map<String, dynamic>>?) ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          store['name'],
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 244, 168, 196),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معرض صور المحل القابل للتمرير والنقر
              if (galleryImages.isNotEmpty) ...[
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    itemCount: galleryImages.length,
                    controller: PageController(viewportFraction: 0.85),
                    itemBuilder: (context, index) {
                      final img = galleryImages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullImageScreen(imagePath: img),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                img,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // معلومات المحل الأساسية
              Text(
                store['name'],
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 244, 168, 196),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                store['description'],
                style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 5),
                  Text(
                    'التقييم: ${store['overall_rating']?.toStringAsFixed(1) ?? 'لا يوجد'}',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.amber[700],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Icon(
                    Icons.local_shipping_outlined,
                    color:
                        store['delivery_available'] ? Colors.blue : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    store['delivery_available']
                        ? 'توصيل متاح'
                        : 'لا يوجد توصيل',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color:
                          store['delivery_available']
                              ? Colors.blue
                              : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // عن المحل (إذا متوفر)
              if (store['details']?['about'] != null) ...[
                Text(
                  'نبذة عن المحل:',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  store['details']['about'],
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // معدات المحددة لهذا المحل
              Text(
                'معدات يقدمها ${store['name']}:',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              specificDistributions.isEmpty
                  ? Text(
                    'لا توجد معدات رحل محددة لهذا المحل حالياً.',
                    style: GoogleFonts.cairo(color: Colors.grey[600]),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: specificDistributions.length,
                    itemBuilder: (context, index) {
                      final dist = specificDistributions[index];
                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  dist['image'],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image_outlined,
                                      size: 30,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dist['name'],
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'السعر: ${dist['price']}',
                                      style: GoogleFonts.cairo(
                                        color: Colors.green[600],
                                      ),
                                    ),
                                    Text(
                                      'المكونات: ${dist['components']}',
                                      style: GoogleFonts.cairo(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'مناسب لـ: ${dist['suitable_for']?.join(', ')}',
                                      style: GoogleFonts.cairo(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (dist['is_customizable'] == true)
                                      Text(
                                        '✨ قابل للتخصيص',
                                        style: GoogleFonts.cairo(
                                          color: const Color.fromARGB(
                                            255,
                                            244,
                                            168,
                                            196,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              const SizedBox(height: 20),

              // تقييمات العملاء
              Text(
                'تقييمات العملاء:',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (customerReviews.isEmpty)
                Text(
                  'لا توجد تقييمات لهذا المحل حتى الآن.',
                  style: GoogleFonts.cairo(color: Colors.grey[600]),
                )
              else
                Column(
                  children:
                      customerReviews.take(3).map((review) {
                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      review['user'] ?? 'مستخدم',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber[700],
                                      size: 16,
                                    ),
                                    Text(
                                      '${review['rating']}',
                                      style: GoogleFonts.cairo(
                                        color: Colors.amber[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  review['comment'],
                                  style: GoogleFonts.cairo(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              if (customerReviews.length > 3)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => FeedbackScreen(distributionId: store['id']),
                      ),
                    );
                  },
                  child: Text(
                    'عرض كل التقييمات (${customerReviews.length})',
                    style: GoogleFonts.cairo(color: Colors.blue),
                  ),
                ),
              const SizedBox(height: 20),

              // زر طلب المعدات
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 244, 168, 196),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // <== هذا هو التعديل الجديد: الانتقال لصفحة الحجز
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BookingScreen(
                              storeName: store['name'],
                              deliveryAvailable: store['delivery_available'],
                            ),
                      ),
                    );
                  },
                  child: Text(
                    '🛒 اطلب معدات من هذا المحل',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
