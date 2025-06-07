import 'package:flutter/material.dart';
import 'full_image_screen.dart';
import 'PhotographerReservationScreen.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotographerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> photographer;

  const PhotographerDetailScreen(this.photographer, {super.key});

  @override
  Widget build(BuildContext context) {
  final averageRating = (photographer['customerReviews'] as List).isNotEmpty
    ? (photographer['customerReviews'] as List)
        .map((e) => (e as num).toDouble())
        .reduce((a, b) => a + b) /
      (photographer['customerReviews'] as List).length
    : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          photographer['name'],
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Text('📍 المدينة: ${photographer['city']}', style: _infoStyle(context)),
                  Text('📷 نوع العمل: ${photographer['mobile'] ? 'ميداني' : 'استوديو فقط'}', style: _infoStyle(context)),
                  Text('⭐ التقييم: ${averageRating.toStringAsFixed(1)}', style: _ratingStyle(context)),
                  Text('💰 نطاق الأسعار: ${photographer['priceRange']}', style: _priceStyle(context)),
                  Text('🎨 أنواع التصوير: ${(photographer['photographyTypes'] as List).join(', ')}', style: _infoStyle(context)),
                  Text('🎉 يصور مناسبات: ${(photographer['eventTypes'] as List).join(', ')}', style: _infoStyle(context)),
                  Text('📞 رقم التواصل: ${photographer['phone']}', style: _infoStyle(context)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('📸 أعمال المصور:', style: _titleStyle(context)),
            SizedBox(height: 10),
            SizedBox(height: 150, child: _buildImageList(context)),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotographerReservationScreen(
                        photographerName: photographer['name'],
                      ),
                    ),
                  );
                },
                child: Text(
                  'احجز الآن',
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  TextStyle _infoStyle(BuildContext context) => GoogleFonts.cairo(
    fontSize: 16,
    color: Colors.black87,
  );

  TextStyle _titleStyle(BuildContext context) => GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple[700],
  );

  TextStyle _ratingStyle(BuildContext context) => GoogleFonts.cairo(
    fontSize: 16,
    color: Colors.amber[700],
    fontWeight: FontWeight.bold,
  );

  TextStyle _priceStyle(BuildContext context) => GoogleFonts.cairo(
    fontSize: 16,
    color: Colors.green[700],
    fontWeight: FontWeight.bold,
  );

  Widget _buildImageList(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: (photographer['portfolioImages'] as List<String>)
          .map<Widget>(
            (img) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImageScreen(imagePath: img),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(img, width: 150, height: 150, fit: BoxFit.cover),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class FullImageScreen extends StatelessWidget {
  final String imagePath;
  const FullImageScreen({super.key, required this.imagePath});

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
          child: Image.asset(imagePath),
        ),
      ),
    );
  }
}