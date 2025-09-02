import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'toolsDetailScreen.dart'; // هذا السطر تم تفعيله لاستيراد صفحة التفاصيل

class DistributionSelectionScreen extends StatefulWidget {
  const DistributionSelectionScreen({super.key});

  @override
  State<DistributionSelectionScreen> createState() =>
      _DistributionSelectionScreenState();
}

class _DistributionSelectionScreenState
    extends State<DistributionSelectionScreen> {
  String? _selectedTripType;
  String? _selectedDistributionType;
  // بيانات المحلات الأولية مع تفاصيلها الكاملة
  final List<Map<String, dynamic>> _allStores = [
    {
      'id': 'store_A',
      'name': 'لمسة فنية للمعدات',
      'description': 'تجهيز معدات فريدة لكل رحلة، بلمسة إبداعية خاصة.',
      'main_image': 'assets/p1.jpg',
      'price_range': 'تبدأ من 7 شيكل',
      'overall_rating': 4.7,
      'delivery_available': true,
      'event_types_covered': [
        'رحلة مسارات',
        'رحلة بحرية',
        'رحلة مغامرات',
        'رحلة جبلية',
        'رحلة تخييم',
      ],
      'distribution_types_offered': ['خيم مغلقة', 'شموع للرحلات', 'معدات خاصة'],
      'details': {
        'about':
            'نحن في "لمسة فنية" نؤمن بأن كل رحلة تستحق لمسة خاصة. نقدم معدات مبتكرة وعملية، مع التركيز على الجودة والتفاصيل الدقيقة.',
        'gallery_images': ['assets/p2.jpg', 'assets/p2.jpg', 'assets/p1.jpg'],
        'specific_distributions': [
          {
            'name': 'معدات حقائب الرحلات',
            'image': 'assets/p1.jpg',
            'price': '8 شيكل/حبة',
            'components': 'حقيبة فاخرة، سحاب مخصص، شريط ذهبي',
            'suitable_for': ['رحلة مسارات', 'رحلة بحرية'],
            'is_customizable': true,
          },
          {
            'name': 'حقيبة أدوات الرحلة',
            'image': 'assets/p1.jpg',
            'price': '18 شيكل/حقيبة',
            'components': 'بوصلة، مصباح صغير، علبة كبريت',
            'suitable_for': ['رحلة تخييم'],
            'is_customizable': false,
          },
        ],
        'customer_reviews': [
          {
            'user': 'Sara K.',
            'rating': 5,
            'comment': 'معداتهم احترافية وجودتها فخمة جداً!.',
          },
          {
            'user': 'Ahmad M.',
            'rating': 4,
            'comment':
                'خدمة رائعة، لكن التوصيل تأخر قليلاً. الجودة تستحق الانتظار.',
          },
          {
            'user': 'Nour A.',
            'rating': 5,
            'comment': 'أفضل مكان للمعدات! إبداع بلا حدود.',
          },
          {
            'user': 'Khaled Z.',
            'rating': 4,
            'comment': 'الأسعار والجودة ممتازة. أوصي بهم للرحلات الخاصة.',
          },
        ],
      },
    },
    {
      'id': 'store_B',
      'name': 'روائع الحقائب للمعدات',
      'description': 'حقائبنا الصغيرة لمسة أناقة في رحلاتكم.',
      'main_image': 'assets/p2.jpg',
      'price_range': 'تبدأ من 12 شيكل',
      'overall_rating': 4.5,
      'delivery_available': false,
      'event_types_covered': ['رحلة بحرية', 'رحلة عائلية', 'رحلة خاصة'],
      'distribution_types_offered': ['حقائب صغيرة', 'حقائب خاصة'],
      'details': {
        'about':
            'في "روائع الحقائب"، نقدم مجموعة مختارة من الحقائب المصغرة ذات الجودة العالية، لتضيف الراحة والعملية على كل رحلة.',
        'gallery_images': ['assets/p1.jpg', 'assets/p1.jpg'],
        'specific_distributions': [
          {
            'name': 'حقائب الرحلات الصغيرة',
            'image': 'assets/p2.jpg',
            'price': '15 شيكل',
            'components': 'حقائب أنيقة، ضد الماء، خفيفة الحمل',
            'suitable_for': ['رحلة بحرية', 'رحلة جبلية'],
            'is_customizable': true,
          },
        ],
        'customer_reviews': [
          {
            'user': 'Layla H.',
            'rating': 5,
            'comment':
                'الحقائب عملية جداً والتغليف مرتب. الكل سألني من وين جبتها.',
          },
          {
            'user': 'Omar S.',
            'rating': 4,
            'comment': 'تجربة رائعة. الحقائب قوية ومناسبة للرحلات.',
          },
        ],
      },
    },
    {
      'id': 'store_C',
      'name': 'معدات الأمل',
      'description': 'متخصصون في معدات التخييم والرحلات الجبلية والبحرية.',
      'main_image': 'assets/s1.jpg',
      'price_range': 'تبدأ من 5 شيكل',
      'overall_rating': 4.9,
      'delivery_available': true,
      'event_types_covered': [
        'رحلة جبلية',
        'رحلة مسارات',
        'رحلة بحرية',
        'رحلة تخييم',
      ],
      'distribution_types_offered': ['خيمة مع فتحة تهوية', 'خيم مخصصة'],
      'details': {
        'about':
            'في "معدات الأمل" نقدم أفضل المعدات اللازمة للتخييم والرحلات بأنواعها، مع تصاميم عملية وجودة عالية تجعل تجربتك أكثر راحة.',
        'gallery_images': ['assets/s2.jpg', 'assets/s2.jpg', 'assets/s1.jpg'],
        'specific_distributions': [
          {
            'name': 'خيمة التخييم المخصصة',
            'image': 'assets/s1.jpg',
            'price': '7 شيكل/خيمة',
            'components': 'خامة مقاومة للمطر، فتحة تهوية، أعمدة متينة',
            'suitable_for': ['رحلة تخييم', 'رحلة جبلية'],
            'is_customizable': true,
          },
          {
            'name': 'خيمة الرحلات السريعة',
            'image': 'assets/p1.jpg',
            'price': '5 شيكل/خيمة',
            'components': 'تصميم قابل للطي، مقاومة للحرارة، سهلة الحمل',
            'suitable_for': ['رحلة بحرية', 'رحلة عائلية'],
            'is_customizable': false,
          },
        ],
        'customer_reviews': [
          {
            'user': 'Reem F.',
            'rating': 5,
            'comment':
                'الخيم عملية جداً وسهلة التركيب. مناسبة للرحلات الطويلة.',
          },
          {
            'user': 'Hasan S.',
            'rating': 5,
            'comment': 'تعامل راقي وخيمهم مريحة وممتازة للجبل والتخييم.',
          },
        ],
      },
    },
    {
      'id': 'store_D',
      'name': 'شمعة أمل للرحلات',
      'description': 'شموع طبيعية محمولة مثالية لأجواء التخييم والرحلات.',
      'main_image': 'assets/s1.jpg',
      'price_range': 'تبدأ من 10 شيكل',
      'overall_rating': 4.2,
      'delivery_available': true,
      'event_types_covered': ['رحلة تخييم', 'رحلة جبلية', 'رحلة ليلية'],
      'distribution_types_offered': ['شموع للرحلات', 'إكسسوارات ضوئية'],
      'details': {
        'about':
            'في "شمعة أمل"، نركز على تقديم شموع طبيعية معطرة ومحمولة، لتمنح أجواء الرحلات دفئاً وجمالاً مع روائح تدوم.',
        'gallery_images': ['assets/s1.jpg', 'assets/s2.jpg'],
        'specific_distributions': [
          {
            'name': 'شموع التخييم المعطرة',
            'image': 'assets/s1.jpg',
            'price': '12 شيكل/شمعة',
            'components': 'شمع صويا، زيوت عطرية طبيعية، علبة معدنية صغيرة',
            'suitable_for': ['رحلة تخييم', 'رحلة جبلية'],
            'is_customizable': true,
          },
          {
            'name': 'شموع الإضاءة الليلية',
            'image': 'assets/p2.jpg',
            'price': '10 شيكل/شمعة',
            'components': 'شمع بارافين، عطر الفواكه، تصميم مضاد للرياح',
            'suitable_for': ['رحلة ليلية', 'رحلة بحرية'],
            'is_customizable': false,
          },
        ],
        'customer_reviews': [
          {
            'user': 'Sami K.',
            'rating': 4,
            'comment': 'الشموع ريحتها رائعة ومناسبة لأجواء التخييم.',
          },
          {
            'user': 'Lina R.',
            'rating': 5,
            'comment': 'فكرة ممتازة للرحلات، الشموع بتعطي أجواء دافئة ومميزة.',
          },
        ],
      },
    },
  ];

  List<Map<String, dynamic>> _filteredStores = [];

  List<String> get _availableTripTypes =>
      {
        'الكل',
        ..._allStores.expand((s) => s['event_types_covered']).toSet(),
      }.toList().cast<String>();

  List<String> get _availableDistributionTypes =>
      {
        'الكل',
        ..._allStores.expand((s) => s['distribution_types_offered']).toSet(),
      }.toList().cast<String>();

  @override
  void initState() {
    super.initState();
    _filteredStores = List.from(_allStores);
  }

  void _filterStores() {
    setState(() {
      _filteredStores =
          _allStores.where((store) {
            final eventTypeMatch =
                _selectedTripType == null ||
                _selectedTripType == 'الكل' ||
                (store['event_types_covered'] as List).contains(
                  _selectedTripType,
                );
            final distributionTypeMatch =
                _selectedDistributionType == null ||
                _selectedDistributionType == 'الكل' ||
                (store['distribution_types_offered'] as List).contains(
                  _selectedDistributionType,
                );
            return eventTypeMatch && distributionTypeMatch;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🛍️ عالم المعدات لرحلاتك',
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
        backgroundColor: const Color.fromARGB(255, 244, 168, 196),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'صفحة الملف الشخصي قيد التطوير!',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'سلة التسوق قيد التطوير!',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTripType,
                    hint: Text('نوع الرحلة', style: GoogleFonts.cairo()),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                    items:
                        _availableTripTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: GoogleFonts.cairo()),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTripType = value;
                        _filterStores();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDistributionType,
                    hint: Text('نوع الغرض', style: GoogleFonts.cairo()),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                    items:
                        _availableDistributionTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: GoogleFonts.cairo()),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDistributionType = value;
                        _filterStores();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _filteredStores.isEmpty
                    ? Center(
                      child: Text(
                        'لا توجد محلات تطابق معايير البحث.',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: _filteredStores.length,
                      itemBuilder: (context, index) {
                        final store = _filteredStores[index];
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: SizedBox(
                              width: 80,
                              height: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  store['main_image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                            title: Text(
                              store['name'],
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  store['description'],
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '💰 ${store['price_range']}',
                                  style: GoogleFonts.cairo(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber[700],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${store['overall_rating']}',
                                      style: GoogleFonts.cairo(
                                        color: Colors.amber[700],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.local_shipping_outlined,
                                      color:
                                          store['delivery_available']
                                              ? Colors.blue
                                              : Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      store['delivery_available']
                                          ? 'توصيل متاح'
                                          : 'لا يوجد توصيل',
                                      style: GoogleFonts.cairo(
                                        color:
                                            store['delivery_available']
                                                ? Colors.blue
                                                : Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color.fromARGB(255, 244, 168, 196),
                            ),
                            onTap: () {
                              // هذا هو الجزء الذي تم تعديله ليعمل الانتقال للصفحة
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ToolsDetailScreen(store: store),
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
    );
  }
}
