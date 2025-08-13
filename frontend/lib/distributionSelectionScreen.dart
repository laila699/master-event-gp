import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'storeDetailScreen.dart'; // هذا السطر تم تفعيله لاستيراد صفحة التفاصيل

class DistributionSelectionScreen extends StatefulWidget {
  const DistributionSelectionScreen({super.key});

  @override
  State<DistributionSelectionScreen> createState() =>
      _DistributionSelectionScreenState();
}

class _DistributionSelectionScreenState
    extends State<DistributionSelectionScreen> {
  String? _selectedEventType;
  String? _selectedDistributionType;

  // بيانات المحلات الأولية مع تفاصيلها الكاملة
  final List<Map<String, dynamic>> _allStores = [
    {
      'id': 'store_A',
      'name': 'لمسة فنية للتوزيعات',
      'description': 'نصمم توزيعات فريدة لكل رحلة، بلمسة إبداعية خاصة.',
      'main_image': 'assets/p1.jpg',
      'price_range': 'تبدأ من 7 شيكل',
      'overall_rating': 4.7,
      'delivery_available': true,
      'event_types_covered': ['زفاف', 'خطوبة', 'مواليد', 'تخرج', 'افتتاح'],
      'distribution_types_offered': ['شوكولاتة مغلفة', 'شموع', 'توزيعات خاصة'],
      'details': {
        'about':
            'نحن في "لمسة فنية" نؤمن بأن كل رحلة تستحق لمسة خاصة. نقدم تصاميم توزيعات مبتكرة وفخمة، مع التركيز على الجودة والتفاصيل الدقيقة.',
        'gallery_images': ['assets/p2.jpg', 'assets/p2.jpg', 'assets/p1.jpg'],
        'specific_distributions': [
          {
            'name': 'توزيعة شوكولاتة الزفاف الفاخرة',
            'image': 'assets/p1.jpg',
            'price': '8 شيكل/حبة',
            'components': 'شوكولاتة بلجيكية فاخرة، تغليف حريري مخصص، شريط ذهبي',
            'suitable_for': ['زفاف', 'خطوبة'],
            'is_customizable': true,
          },
          {
            'name': 'شموع معطرة للمواليد',
            'image': 'assets/p1.jpg',
            'price': '18 شيكل/شمعة',
            'components':
                'شموع صويا طبيعية، زيوت عطرية فرنسية، علبة كريستال أنيقة',
            'suitable_for': ['مواليد'],
            'is_customizable': false,
          },
        ],
        'customer_reviews': [
          {
            'user': 'Sara K.',
            'rating': 5,
            'comment':
                'شغلهم احترافي والتوزيعات فخمة جداً! كانت لمسة مميزة في زفافي.',
          },
          {
            'user': 'Ahmad M.',
            'rating': 4,
            'comment':
                'خدمة رائعة، ولكن التوصيل أخذ وقت أطول مما توقعت بقليل. الجودة تستاهل الانتظار.',
          },
          {
            'user': 'Nour A.',
            'rating': 5,
            'comment': 'أفضل مكان لتصميم التوزيعات! إبداع بلا حدود.',
          },
          {
            'user': 'Khaled Z.',
            'rating': 4,
            'comment':
                'الأسعار رحلة والجودة ممتازة. أوصي بهم للمناسبات الخاصة.',
          },
        ],
      },
    },
    {
      'id': 'store_B',
      'name': 'روائع العطور للتوزيعات',
      'description': 'عطورنا الصغيرة لمسة أناقة في مناسباتكم.',
      'main_image': 'assets/p2.jpg',
      'price_range': 'تبدأ من 12 شيكل',
      'overall_rating': 4.5,
      'delivery_available': false,
      'event_types_covered': ['تخرج', 'عيد ميلاد', 'هدايا'],
      'distribution_types_offered': ['عطور صغيرة', 'توزيعات خاصة'],
      'details': {
        'about':
            'في روائع العطور، نقدم مجموعة مختارة من العطور المصغرة والتوزيعات ذات الروائح الفاخرة، لتضيف لمسة من الرقي على احتفالاتكم.',
        'gallery_images': ['assets/p1.jpg', 'assets/p1.jpg'],
        'specific_distributions': [
          {
            'name': 'عبوات عطر التخرج',
            'image': 'assets/p2.jpg',
            'price': '15 شيكل/عبوة',
            'components': 'عطر مركز، زجاجة أنيقة، كرت معايدة بتصميم خاص',
            'suitable_for': ['تخرج'],
            'is_customizable': true,
          },
        ],
        'customer_reviews': [
          {
            'user': 'Layla H.',
            'rating': 5,
            'comment':
                'العطور ريحتها بتجنن والتغليف فخم جداً. الكل سألني من وين جبتهم.',
          },
          {
            'user': 'Omar S.',
            'rating': 4,
            'comment': 'كانت تجربة ممتازة، أوصي بها بشدة. جودة العطور رائعة.',
          },
        ],
      },
    },
    {
      'id': 'store_C',
      'name': 'حلا وشوكولا',
      'description': 'تخصصنا في الشوكولاتة الفاخرة لجميع المناسبات.',
      'main_image': 'assets/s1.jpg',
      'price_range': 'تبدأ من 5 شيكل',
      'overall_rating': 4.9,
      'delivery_available': true,
      'event_types_covered': ['زفاف', 'مواليد', 'خطوبة', 'عيد ميلاد'],
      'distribution_types_offered': ['شوكولاتة مغلفة', 'حلوى مخصصة'],
      'details': {
        'about':
            'نقدم أجود أنواع الشوكولاتة بتصاميم تغليف مبتكرة تناسب كافة الاحتفالات، من الأفراح إلى أعياد الميلاد. طعم لا يُنسى وتصميم يلفت الأنظار.',
        'gallery_images': ['assets/s2.jpg', 'assets/s2.jpg', 'assets/s1.jpg'],
        'specific_distributions': [
          {
            'name': 'صناديق شوكولاتة الزفاف المخصصة',
            'image': 'assets/s1.jpg',
            'price': '7 شيكل/قطعة',
            'components': 'شوكولاتة داكنة وحليب، حشوات متنوعة، صندوق خشبي صغير',
            'suitable_for': ['زفاف', 'خطوبة'],
            'is_customizable': true,
          },
          {
            'name': 'توزيعات شوكولاتة المواليد',
            'image': 'assets/p1.jpg',
            'price': '5 شيكل/قطعة',
            'components': 'شوكولاتة بالحليب، تغليف ملون، أشكال أطفال',
            'suitable_for': ['مواليد'],
            'is_customizable': false,
          },
        ],
        'customer_reviews': [
          {
            'user': 'Reem F.',
            'rating': 5,
            'comment':
                'الشوكولاتة خرافية والتغليف أنيق جداً. كانت توزيعات مثالية لرحلة خطوبتي.',
          },
          {
            'user': 'Hasan S.',
            'rating': 5,
            'comment': 'تعامل راقي ومنتجاتهم بتفتح النفس. دايماً بطلب منهم.',
          },
        ],
      },
    },
    {
      'id': 'store_D',
      'name': 'شمعة أمل',
      'description': 'شموع طبيعية مصنوعة يدوياً برائحة تدوم.',
      'main_image': 'assets/s1.jpg',
      'price_range': 'تبدأ من 10 شيكل',
      'overall_rating': 4.2,
      'delivery_available': true,
      'event_types_covered': ['زفاف', 'تخرج', 'هدايا'],
      'distribution_types_offered': ['شموع', 'توزيعات خاصة'],
      'details': {
        'about':
            'في "شمعة أمل"، نركز على تقديم شموع معطرة طبيعية مصنوعة بحب وجودة عالية، لتمنح مناسباتك الدفء والجمال بأسعار رحلة للجميع.',
        'gallery_images': ['assets/s1.jpg', 'assets/s2.jpg'],
        'specific_distributions': [
          {
            'name': 'شموع الزفاف المعطرة',
            'image': 'assets/s1.jpg',
            'price': '12 شيكل/شمعة',
            'components': 'شمع صويا، زيوت الورد والياسمين، علبة زجاجية بسيطة',
            'suitable_for': ['زفاف', 'خطوبة'],
            'is_customizable': true,
          },
          {
            'name': 'شموع التخرج الملونة',
            'image': 'assets/p2.jpg',
            'price': '10 شيكل/شمعة',
            'components': 'شمع بارافين، ألوان زاهية، عطر الفواكه',
            'suitable_for': ['تخرج'],
            'is_customizable': false,
          },
        ],
        'customer_reviews': [
          {
            'user': 'Sami K.',
            'rating': 4,
            'comment': 'الشموع ريحتها حلوة بس حجمها أصغر من الصورة.',
          },
          {
            'user': 'Lina R.',
            'rating': 5,
            'comment': 'أحببت فكرة التوزيعات بالشموع، والمحل قدم خدمة ممتازة.',
          },
        ],
      },
    },
  ];

  List<Map<String, dynamic>> _filteredStores = [];

  List<String> get _availableEventTypes =>
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
                _selectedEventType == null ||
                _selectedEventType == 'الكل' ||
                (store['event_types_covered'] as List).contains(
                  _selectedEventType,
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
          '🛍️ عالم التوزيعات لمناسباتك',
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
                    value: _selectedEventType,
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
                        _availableEventTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: GoogleFonts.cairo()),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEventType = value;
                        _filterStores();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDistributionType,
                    hint: Text('نوع التوزيعة', style: GoogleFonts.cairo()),
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
                                      (_) => StoreDetailScreen(store: store),
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
