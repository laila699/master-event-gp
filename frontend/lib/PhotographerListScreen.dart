import 'package:flutter/material.dart';
import 'photographerDetailScreen.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotographerListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialPhotographers = [
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

  PhotographerListScreen({super.key});

  @override
  State<PhotographerListScreen> createState() => _PhotographerListScreenState();
}

class _PhotographerListScreenState extends State<PhotographerListScreen> {
  String? _selectedCity;
  String? _selectedEventType;
  List<Map<String, dynamic>> _filteredPhotographers = [];

  List<String> get _availableCities =>
      {
        'الكل',
        ...widget.initialPhotographers.map((p) => p['city']).toSet(),
      }.toList().cast<String>();
  List<String> get _availableEventTypes =>
      {
        'الكل',
        ...widget.initialPhotographers.expand((p) => p['eventTypes']).toSet(),
      }.toList().cast<String>();

  @override
  void initState() {
    super.initState();
    _filteredPhotographers = List.from(widget.initialPhotographers);
  }

  void _filterPhotographers() {
    setState(() {
      _filteredPhotographers =
          widget.initialPhotographers.where((photographer) {
            final cityMatch =
                _selectedCity == null ||
                _selectedCity == 'الكل' ||
                photographer['city'] == _selectedCity;
            final eventTypeMatch =
                _selectedEventType == null ||
                _selectedEventType == 'الكل' ||
                (photographer['eventTypes'] as List).contains(
                  _selectedEventType,
                );
            return cityMatch && eventTypeMatch;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' 📸 اختر مصور مناسبتك',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB( 255, 244, 168, 196),
      ),
      backgroundColor: Color(0xFFF7F7F7), // لون الخلفية من فرونت المطاعم
      body: SingleChildScrollView(
        // إضافة SingleChildScrollView هنا
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // فلتر المدينة
                  DropdownButton<String>(
                    value: _selectedCity,
                    hint: Text('المدينة', style: GoogleFonts.cairo()),
                    items:
                        _availableCities.map((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city, style: GoogleFonts.cairo()),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                        _filterPhotographers();
                      });
                    },
                  ),
                  // فلتر نوع المناسبة
                  DropdownButton<String>(
                    value: _selectedEventType,
                    hint: Text('نوع المناسبة', style: GoogleFonts.cairo()),
                    items:
                        _availableEventTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: GoogleFonts.cairo()),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEventType = value;
                        _filterPhotographers();
                      });
                    },
                  ),
                ],
              ),
            ),
            ListView.builder(
              physics:
                  NeverScrollableScrollPhysics(), // لمنع تداخل السكرول مع SingleChildScrollView
              shrinkWrap: true, // لجعل حجم ListView مناسبًا لمحتواه
              padding: const EdgeInsets.all(12.0),
              itemCount: _filteredPhotographers.length,
              itemBuilder: (context, index) {
                final photographer = _filteredPhotographers[index];
                final imagePath =
                    (photographer['portfolioImages'] as List<String>).isNotEmpty
                        ? photographer['portfolioImages'][0]
                        : 'assets/default_profile.jpg';
                final customerReviews =
                    (photographer['customerReviews'] as List).cast<num>();
                final averageRating =
                    customerReviews.isNotEmpty
                        ? customerReviews
                                .map((e) => e.toDouble())
                                .reduce((a, b) => a + b) /
                            customerReviews.length
                        : 0.0;
                return Card(
                  color: Colors.white, // لون الكارد أبيض
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(imagePath),
                      radius: 30,
                    ),
                    title: Text(
                      photographer['name'],
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          '📍 ${photographer['city']}',
                          style: GoogleFonts.cairo(color: Colors.grey[600]),
                        ),
                        Text(
                          '📸 أنواع التصوير: ${(photographer['photographyTypes'] as List).join(', ')}',
                          style: GoogleFonts.cairo(color: Colors.grey[600]),
                        ),
                        Text(
                          '⭐ التقييم: ${averageRating.toStringAsFixed(1)}',
                          style: GoogleFonts.cairo(color: Colors.amber[700]),
                        ),
                        Text(
                          '💰 ${photographer['priceRange']}',
                          style: GoogleFonts.cairo(color: Colors.green[700]),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.purple,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => PhotographerDetailScreen(photographer),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
