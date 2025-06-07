import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // لعرض النجوم بشكل تفاعلي

class FeedbackScreen extends StatelessWidget {
  final String distributionId; // معرف التوزيعة لجلب التقييمات الخاصة بها

  // بيانات تقييمات مؤقتة (في التطبيق الفعلي، هذه البيانات حتكون من API أو قاعدة بيانات)
  final Map<String, List<Map<String, dynamic>>> _allFeedback = {
    'chocolate1': [
      {'userId': 'user1', 'rating': 5, 'comment': 'شوكولاتة رائعة وتغليف ممتاز!'},
      {'userId': 'user2', 'rating': 4, 'comment': 'لذيذة ولكن التوصيل تأخر قليلاً.'},
      {'userId': 'user3', 'rating': 5, 'comment': 'أفضل شوكولاتة مناسبات طلبتها على الإطلاق.'},
    ],
    'candle1': [
      {'userId': 'user4', 'rating': 4, 'comment': 'الرائحة جميلة جداً والشكل أنيق.'},
      {'userId': 'user5', 'rating': 3, 'comment': 'الحجم أصغر مما توقعت.'},
    ],
    // ... المزيد من التقييمات حسب معرف التوزيعة
  };

  FeedbackScreen({super.key, required this.distributionId});

  List<Map<String, dynamic>> get _distributionFeedback => _allFeedback[distributionId] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('⭐ تقييمات العملاء', style: GoogleFonts.cairo()),
        backgroundColor: Colors.amber[700],
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: _distributionFeedback.isEmpty
          ? Center(
              child: Text('لا يوجد تقييمات لهذه التوزيعة حتى الآن.', style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[600])),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _distributionFeedback.length,
              itemBuilder: (context, index) {
                final feedback = _distributionFeedback[index];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(feedback['userId'] ?? 'مستخدم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        RatingBarIndicator(
                          rating: feedback['rating'].toDouble(),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(height: 8),
                        Text(feedback['comment'], style: GoogleFonts.cairo(fontSize: 16)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
