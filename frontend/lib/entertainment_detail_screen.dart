// lib/entertainment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_screen4.dart'; // <== تأكدي من أن هذا هو المسار الصحيح واسم الملف

class EntertainmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> entertainmentOption;

  const EntertainmentDetailScreen({super.key, required this.entertainmentOption});

  @override
  Widget build(BuildContext context) {
    final List<String> galleryImages = (entertainmentOption['details']?['gallery_images'] as List<String>?) ?? [];
    if (galleryImages.isEmpty && entertainmentOption['image'] != null) {
      galleryImages.add(entertainmentOption['image']);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          entertainmentOption['name'],
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('عرض الصورة بحجم كامل: $img', style: GoogleFonts.cairo())),
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
                                return Container(
                                  height: 250,
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey)),
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

            Text(
              entertainmentOption['name'],
              style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            Text(
              entertainmentOption['description'],
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 10),
            Text(
              '💰 ${entertainmentOption['price_range']}',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            const SizedBox(height: 20),

            if (entertainmentOption['details'] != null) ...[
              Text('تفاصيل إضافية:', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (entertainmentOption['details']['duration'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'المدة: ${entertainmentOption['details']['duration']}',
                        style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              if (entertainmentOption['details']['requirements'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.checklist_rtl_outlined, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'المتطلبات: ${entertainmentOption['details']['requirements']}',
                          style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              if (entertainmentOption['details']['customize_songs'] == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.music_note, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '🎵 يمكن طلب أغاني مخصصة',
                        style: GoogleFonts.cairo(fontSize: 15, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              if (entertainmentOption['details']['genre'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.theater_comedy_outlined, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'النوع: ${entertainmentOption['details']['genre']?.join(', ')}',
                        style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              if (entertainmentOption['details']['age_group'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.child_care, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'الفئة العمرية: ${entertainmentOption['details']['age_group']}',
                        style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],

            Text(
              'يناسب المناسبات التالية:',
              style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: (entertainmentOption['suitable_for_events'] as List<String>)
                  .map((event) => Chip(
                        label: Text(event, style: GoogleFonts.cairo(fontSize: 13)),
                        backgroundColor: Colors.deepPurple.shade100,
                        labelStyle: GoogleFonts.cairo(color: Colors.deepPurple.shade800),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: () {
                  // <== هذا هو التعديل الأساسي هنا
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        // نمرر اسم العرض كـ 'serviceName' الآن
                        serviceName: entertainmentOption['name'],
                      ),
                    ),
                  );
                },
                child: Text('➕ اطلب هذا العرض', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}