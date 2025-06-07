import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'RestaurantDetailsScreen.dart';

class RestaurantListScreen extends StatefulWidget {
  @override
  _RestaurantListScreenState createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
 final List<Map<String, dynamic>> _allRestaurants = [
  {
    'name': 'fareed zamano',
    'image': 'assets/fareed.jpg',
    'rating': 4.7,
    'location': 'رفيديا - نابلس',
    'phone': '0593130136',
    'foodImages': ['assets/f1.jpg', 'assets/f2.jpg'],
    'city': 'نابلس',
    'customerReviews': [
      {
        'name': 'أحمد',
        'rating': 5,
        'comment': 'طعام ممتاز وخدمة رائعة!',
      },
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
      {
        'name': 'سعيد',
        'rating': 4,
        'comment': 'الطعام شهي والمكان نظيف.',
      },
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
       {
        'name': 'منى',
        'rating': 5,
        'comment': 'أفضل بوفيه حضرته على الإطلاق!',
      },
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
      {
        'name': 'منى',
        'rating': 5,
        'comment': 'أفضل بوفيه حضرته على الإطلاق!',
      },
    ],
  },
];

    
 

  List<Map<String, dynamic>> _filteredRestaurants = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = List.from(_allRestaurants); // تهيئة القائمة المفلترة بكل المطاعم
  }

  void _filterRestaurants(String city) {
    setState(() {
      if (city.isEmpty) {
        _filteredRestaurants = List.from(_allRestaurants);
      } else {
        _filteredRestaurants = _allRestaurants
            .where((res) => res['city'].toLowerCase().contains(city.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                'قائمة المطاعم التي توفر بوفيهات للمناسبات',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'أدخل اسم المدينة',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  _filterRestaurants(value);
                },
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final res = _filteredRestaurants[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          res['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        res['name'],
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'التقييم: ${res['rating']}',
                        style: GoogleFonts.cairo(),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantDetailsScreen(
                              name: res['name'],
                              location: res['location'],
                              rating: res['rating'].toDouble(),
                              phone: res['phone'],
                              reviewImages: List<String>.from(res['foodImages'] ?? []),
                                customerReviews: res['customerReviews'] ?? [], 
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}