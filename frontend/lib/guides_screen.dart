// lib/entertainment_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'guides_detail_screen.dart'; // تأكدي من المسار الصحيح لشاشة التفاصيل

// 1. بيانات جميع المرشدين  (الآن مدمجة هنا)
final List<Map<String, dynamic>> allToolsOptions = [
  {
    'id': 'heritage_tour',
    'name': 'مرشد التراث التاريخي',
    'description':
        'مرشد سياحي يأخذكم في رحلة عبر المواقع التاريخية القديمة، يروي قصص الماضي ويعرض جمال العمارة التقليدية. مناسب للمجموعات والرحلات المدرسية والسياحية.',
    'image': 'assets/heritage1.jpg',
    'price_range': 'تبدأ من 150 شيكل للشخص',
    'suitable_for_events': ['رحلة مدرسية', 'سياحة', 'رحلة جماعية'],
    'details': {
      'duration': 'ساعتان',
      'requirements': 'أحذية مريحة للمشي، قبعة للشمس.',
      'languages': ['العربية', 'الإنجليزية'],
      'gallery_images': ['assets/heritage2.jpg', 'assets/heritage3.jpg'],
    },
  },
  {
    'id': 'nature_trip',
    'name': 'مرشد طبيعة واستكشاف',
    'description':
        'رحلة ميدانية يقودها مرشد مختص في الطبيعة، لاستكشاف الغابات والأنهار والتعرف على النباتات والحيوانات المحلية. نشاط مليء بالمغامرة والتعلم.',
    'image': 'assets/nature1.jpg',
    'price_range': 'تبدأ من 100 شيكل للشخص',
    'suitable_for_events': ['رحلة عائلية', 'تعليمية', 'مغامرة شبابية'],
    'details': {
      'duration': '3 ساعات',
      'requirements': 'ملابس مريحة، ماء للشرب.',
      'age_group': '10 سنوات فأكثر',
      'gallery_images': ['assets/nature2.jpg', 'assets/nature3.jpg'],
    },
  },
  {
    'id': 'food_tour',
    'name': 'مرشد المذاقات المحلية',
    'description':
        'اصطحابكم مع مرشد لتذوق الأطعمة الشعبية والمأكولات التقليدية من مطاعم وأسواق محلية، مع شرح عن تاريخ الأطباق وثقافة الطعام.',
    'image': 'assets/food1.jpg',
    'price_range': 'تبدأ من 200 شيكل للشخص',
    'suitable_for_events': ['سياحة', 'أصدقاء', 'رحلة عمل'],
    'details': {
      'duration': '3 ساعات',
      'requirements': 'شهية مفتوحة وتجربة جديدة.',
      'customize_menu': true,
      'gallery_images': [
        'assets/food2.jpg',
        'assets/food_gallery1.jpg',
        'assets/food_gallery2.jpg',
      ],
    },
  },
  {
    'id': 'kids_culture',
    'name': 'مرشد للأطفال',
    'description':
        'برنامج ترفيهي وتثقيفي للأطفال مع مرشد يزور معهم متاحف وأماكن تعليمية بطريقة ممتعة، مع أنشطة وألعاب مرتبطة بالثقافة والتاريخ.',
    'image': 'assets/kids_culture.jpg',
    'price_range': 'تبدأ من 80 شيكل للطفل',
    'suitable_for_events': ['تعليمية', 'رحلة عائلية'],
    'details': {
      'duration': '90 دقيقة',
      'requirements': 'مرافقة مشرفين من المدرسة أو الأهل.',
      'age_group': '6-12 سنة',
      'gallery_images': [
        'assets/kids_gallery1.jpg',
        'assets/kids_gallery2.jpg',
      ],
    },
  },
  {
    'id': 'adventure_trip',
    'name': 'مرشد مغامرة وتسلق',
    'description':
        'نشاط يقوده مرشد محترف لممارسة التسلق واستكشاف الكهوف والمرتفعات. مناسب لعشاق المغامرات والأنشطة الخارجية.',
    'image': 'assets/adventure.jpg',
    'price_range': 'تبدأ من 250 شيكل للشخص',
    'suitable_for_events': ['نشاط شبابي', 'مغامرة'],
    'details': {
      'duration': '4 ساعات',
      'requirements': 'لياقة بدنية جيدة، معدات تسلق (توفر حسب الطلب).',
      'age_group': '16+',
    },
  },
  {
    'id': 'cultural_festival',
    'name': 'مرشد المهرجانات الثقافية',
    'description':
        'مرشد سياحي يرافقكم لحضور مهرجانات محلية وعروض فولكلورية، مع شرح عن العادات والتقاليد والموسيقى الشعبية.',
    'image': 'assets/festival.jpg',
    'price_range': 'تبدأ من 180 شيكل للشخص',
    'suitable_for_events': ['ثقافية', 'سياحة', 'تعليمية'],
    'details': {
      'duration': 'ساعتان',
      'requirements': 'اهتمام بالثقافة والفنون.',
      'languages': ['العربية', 'الإنجليزية'],
    },
  },
];

// 2. شاشة العرض مع وظائف البحث والفلترة
class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  String _searchQuery = '';
  String? _selectedTripType; // لتخزين نوع الرحلة المختار من الفلترة

  // قائمة بأنواع المناسبات التي ستظهر في الـ Dropdown
  final List<String> _tripTypes = [
    'جميع الرحل', // هذا الخيار سيعرض كل الفرق
    'رحل ثقافية',
    'رجل دينية',
    'رحل مسارات',
    'رحلات بحرية',
    'رحلات مغامرات ',
    'رحل تزلج',
    'رحل خاصة',
    'رحل عائلية',
    'رحل تسلق',
    'رحلة أخرى',
  ];

  @override
  Widget build(BuildContext context) {
    // بناء القائمة المفلترة بناءً على البحث ونوع الرحلة
    List<Map<String, dynamic>> filteredEntertainmentOptions =
        allToolsOptions.where((option) {
          // شرط البحث عن طريق الاسم
          final nameMatches = option['name'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

          // شرط الفلترة حسب نوع الرحلة
          final eventTypeMatches =
              _selectedTripType == null || // إذا لم يتم اختيار شيء
              _selectedTripType ==
                  'جميع الرحلات ' || // أو إذا اختار "جميع الرحلات"
              (option['suitable_for_events']
                      as List<
                        String
                      >) // أو إذا كانت الرحلة المختارة موجودة في قائمة الرحلات
                  .contains(_selectedTripType);

          return nameMatches &&
              eventTypeMatches; // يجب أن يتحقق الشرطان (البحث والفلترة)
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' مرشدين الرحلات', // العنوان الثابت للصفحة
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 244, 168, 196),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // حقل البحث
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery =
                          value; // تحديث قيمة البحث وإعادة بناء الواجهة
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مرشد  ...',
                    hintStyle: GoogleFonts.cairo(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: Colors.purple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 15),

                // قائمة الفلترة حسب نوع الرحلة
                DropdownButtonFormField<String>(
                  value: _selectedTripType,
                  hint: Text(
                    'اختر رحلتك',
                    style: GoogleFonts.cairo(color: Colors.grey[600]),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                  ),
                  items:
                      _tripTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: GoogleFonts.cairo(color: Colors.black87),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTripType =
                          value; // تحديث نوع الرحلة وإعادة بناء الواجهة
                    });
                  },
                  style: GoogleFonts.cairo(fontSize: 16),
                  dropdownColor: Colors.white,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color.fromARGB(255, 244, 168, 196),
                  ),
                ),
              ],
            ),
          ),
          // عرض رسالة إذا لم يتم العثور على نتائج
          Expanded(
            child:
                filteredEntertainmentOptions.isEmpty
                    ? Center(
                      child: Text(
                        'لا توجد عروض مطابقة لمعايير البحث أو الفلترة.',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredEntertainmentOptions.length,
                      itemBuilder: (context, index) {
                        final option = filteredEntertainmentOptions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EntertainmentDetailScreen(
                                        entertainmentOption: option,
                                      ),
                                ),
                              );
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
                                      option['image'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      // هذا الجزء يعرض أيقونة إذا لم يتم العثور على الصورة
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option['name'],
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromARGB(
                                              255,
                                              244,
                                              168,
                                              196,
                                            ),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          option['description'],
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '💰 ${option['price_range']}',
                                          style: GoogleFonts.cairo(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Wrap(
                                          spacing: 6.0,
                                          runSpacing: 4.0,
                                          children:
                                              (option['suitable_for_events']
                                                      as List<String>)
                                                  .take(
                                                    3,
                                                  ) // عرض أول 3 مناسبات فقط
                                                  .map(
                                                    (event) => Chip(
                                                      label: Text(
                                                        event,
                                                        style:
                                                            GoogleFonts.cairo(
                                                              fontSize: 11,
                                                            ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.purple.shade50,
                                                      labelStyle:
                                                          GoogleFonts.cairo(
                                                            color:
                                                                Colors
                                                                    .purple
                                                                    .shade700,
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
          ),
        ],
      ),
    );
  }
}
