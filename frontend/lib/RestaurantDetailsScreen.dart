import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ReservationScreen.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String phone;
  final List<String> reviewImages;
  final List<Map<String, dynamic>> customerReviews;

  final List<String> buffetMenu = [
    'مقبلات متنوعة (حمص، متبل، فتوش، تبولة)',
    'أطباق رئيسية (مندي لحم، كبسة دجاج، مقلوبة باذنجان)',
    'أطباق جانبية (أرز أبيض، خضار سوتيه)',
    'حلويات شرقية (كنافة، بقلاوة، قطايف)',
    'مشروبات (عصائر طازجة، مياه غازية)',
  ];

  RestaurantDetailsScreen({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.phone,
    required this.reviewImages,
    required this.customerReviews,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.cairo(
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Colors.black87,
    );

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المطعم
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFD6EAF8),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📍 الموقع: $location', style: textStyle),
                  SizedBox(height: 8),
                  Text('⭐ التقييم العام: $rating', style: textStyle),
                  SizedBox(height: 8),
                  Text('📞 رقم التواصل: $phone', style: textStyle),
                ],
              ),
            ),

            SizedBox(height: 20),

            Text(
              '📸 بعض الأطباق التي يقدمها المطعم:',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // صور الأطباق
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: reviewImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FullScreenImage(
                                  imagePath: reviewImages[index],
                                ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          reviewImages[index], // ✅ تم حذف 'assets/' لتجنب التكرار
                          width: 200,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 25),

            // المنيو
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📜 المنيو المقترح للبوفيهات:',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 244, 168, 196),
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        buffetMenu
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  '• $item',
                                  style: GoogleFonts.cairo(),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // تقييمات الزبائن
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💬 تقييمات الزبائن السابقين:',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 244, 168, 196),
                    ),
                  ),
                  SizedBox(height: 10),
                  customerReviews.isEmpty
                      ? Text(
                        'لا يوجد تقييمات حتى الآن.',
                        style: GoogleFonts.cairo(),
                      )
                      : Column(
                        children:
                            customerReviews
                                .map(
                                  (review) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${review['name']} ',
                                              style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 18,
                                            ),
                                            Text(
                                              ' (${review['rating']}/5)',
                                              style: GoogleFonts.cairo(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${review['comment']}',
                                          style: GoogleFonts.cairo(),
                                        ),
                                        Divider(),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // زر الحجز
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 244, 168, 196),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReservationScreen(restaurantName: name),
                    ),
                  );
                },
                child: Text(
                  'احجز الآن',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;
  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.asset(
            imagePath,
          ), // ✅ حذف 'assets/' لأنك تمرر المسار كامل
        ),
      ),
    );
  }
}
