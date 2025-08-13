// lib/entertainment_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'guides_detail_screen.dart'; // تأكدي من المسار الصحيح لشاشة التفاصيل

// 1. بيانات جميع الفرق والعروض (الآن مدمجة هنا)
final List<Map<String, dynamic>> allToolsOptions = [
  {
    'id': 'debka_pro',
    'name': 'فرقة شمس للأعراس ',
    'description':
        'فرقة دبكة مكونة من ٨ راقصين مع موسيقى حية، رحلة للأفراح والمناسبات الكبيرة. نقدم عروضًا مميزة تجذب الجمهور وتضفي جوًا من البهجة.',
    'image': 'assets/dd1.jpg',
    'price_range': 'تبدأ من 800 شيكل',
    'suitable_for_events': ['زفاف', 'خطوبة', 'تخرج', 'افتتاح'],
    'details': {
      'duration': '30 دقيقة',
      'requirements': 'مساحة رحلة للرقص، نظام صوت جيد.',
      'customize_songs': true,
      'gallery_images': ['assets/sh1.jpg', 'assets/sh2.jpg'],
    },
  },
  {
    'id': 'dabke_small',
    'name': 'فقرة طلت الاستعراضية',
    'description':
        'وصلة دبكة مكونة من ٤ راقصين مع موسيقى مسجلة، رحلة للمناسبات العائلية الصغيرة والتجمعات. أداء حيوي وممتع يناسب جميع الأذواق.',
    'image': 'assets/tal1.jpg',
    'price_range': 'تبدأ من 400 شيكل',
    'suitable_for_events': ['زفاف', 'خطوبة', 'عيد ميلاد', 'رحلة أخرى'],
    'details': {
      'duration': '15 دقيقة',
      'requirements': 'نظام صوت أساسي.',
      'customize_songs': false,
      'gallery_images': ['assets/tal2.jpg', 'assets/tal3.jpg'],
    },
  },
  {
    'id': 'band_arabic',
    'name': 'فرقة الأفندي ',
    'description':
        'فرقة موسيقية متكاملة (عود، طبل، قانون) لتقديم مجموعة من الأغاني العربية الكلاسيكية والحديثة. إضفاء أجواء الطرب الأصيل على مناسبتكم.',
    'image': 'assets/band1.jpg',
    'price_range': 'تبدأ من 1500 شيكل',
    'suitable_for_events': ['زفاف', 'خطوبة', 'افتتاح'],
    'details': {
      'duration': 'ساعتان',
      'requirements': 'منصة، نظام صوت احترافي، إضاءة.',
      'customize_songs': true,
      'genre': ['طرب', 'كلاسيكي', 'حديث'],
      'gallery_images': [
        'assets/band1.jpg',
        'assets/band_gallery1.jpg',
        'assets/band_gallery2.jpg',
      ],
    },
  },
  {
    'id': 'kids_show',
    'name': 'فرقة قوس قزح ',
    'description':
        'شخصيات كرتونية محبوبة تتفاعل مع الأطفال، تتضمن فقرات رقص وألعاب وتوزيع هدايا. لمتعة أطفالكم في كل المناسبات.',
    'image': 'assets/kids_show.jpg',
    'price_range': 'تبدأ من 300 شيكل',
    'suitable_for_events': ['مواليد', 'عيد ميلاد', 'حفل مدرسي'],
    'details': {
      'duration': '45 دقيقة',
      'requirements': 'مساحة لعب آمنة، نظام صوت بسيط.',
      'age_group': '3-10 سنوات',
      'gallery_images': ['assets/kids_show.jpg', 'assets/kids_gallery1.jpg'],
    },
  },
  {
    'id': 'magic_show',
    'name': 'فرقة تكات ومسابقات',
    'description':
        'ساحر محترف يقدم عروضًا شيقة ومسابقات تفاعلية للأطفال والكبار، رحلة لجميع الاحتفالات.',
    'image': 'assets/magic_show.jpg', // تأكدي من توفر هذه الصورة
    'price_range': 'تبدأ من 500 شيكل',
    'suitable_for_events': ['عيد ميلاد', 'حفل مدرسي', 'رحلة أخرى'],
    'details': {
      'duration': '60 دقيقة',
      'requirements': 'مسرح صغير، إضاءة رحلة.',
      'age_group': 'جميع الأعمار',
    },
  },
  {
    'id': 'folk_dance',
    'name': 'فرقة فلكلور',
    'description':
        'مجموعة من الراقصين يقدمون عروض رقص فلكلورية من ثقافات مختلفة (مثل رقصات خليجية أو شامية)، مع أزياء تقليدية.',
    'image': 'assets/folk_dance.jpg', // تأكدي من توفر هذه الصورة
    'price_range': 'تبدأ من 700 شيكل',
    'suitable_for_events': ['زفاف', 'افتتاح', 'تخرج', 'رحلة أخرى'],
    'details': {
      'duration': '25 دقيقة',
      'requirements': 'مساحة واسعة للرقص.',
      'customize_songs': true,
      'genre': ['فلكلور', 'شعبي'],
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
  String? _selectedEventType; // لتخزين نوع الرحلة المختار من الفلترة

  // قائمة بأنواع المناسبات التي ستظهر في الـ Dropdown
  final List<String> _tripTypes = [
    'جميع المناسبات', // هذا الخيار سيعرض كل الفرق
    'زفاف',
    'خطوبة',
    'مواليد',
    'تخرج',
    'عيد ميلاد',
    'افتتاح',
    'حفلات خاصة',
    'مهرجانات',
    'حفل مدرسي',
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
              _selectedEventType == null || // إذا لم يتم اختيار شيء
              _selectedEventType ==
                  'جميع المناسبات' || // أو إذا اختار "جميع المناسبات"
              (option['suitable_for_events']
                      as List<
                        String
                      >) // أو إذا كانت الرحلة المختارة موجودة في قائمة المناسبات للفرقة
                  .contains(_selectedEventType);

          return nameMatches &&
              eventTypeMatches; // يجب أن يتحقق الشرطان (البحث والفلترة)
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الترفيه والعروض', // العنوان الثابت للصفحة
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
                    hintText: 'ابحث عن فرقة أو عرض...',
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
                  value: _selectedEventType,
                  hint: Text(
                    'اختر مناسبتك',
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
                      _selectedEventType =
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
