// lib/distribution_provider_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/manage_distribution_store_screen.dart';

// **ملاحظة:** في التطبيق الحقيقي، هذه القائمة ستأتي من الـ Backend
// لكن لأغراض الـ Front-end، سنستخدم هذه البيانات كمثال
final List<Map<String, dynamic>> myDistributionStores = [
  {
    'id': 'store_A',
    'name': 'لمسة فنية للتوزيعات',
    'description': 'نصمم توزيعات فريدة لكل مناسبة، بلمسة إبداعية خاصة.',
    'main_image': 'assets/p1.jpg', // تأكدي من وجود هذه الصورة
    'price_range': 'تبدأ من 7 شيكل',
    'overall_rating': 4.7,
    'delivery_available': true,
    'event_types_covered': ['زفاف', 'خطوبة', 'مواليد', 'تخرج', 'افتتاح'],
    'distribution_types_offered': ['شوكولاتة مغلفة', 'شموع', 'توزيعات خاصة'],
    'details': {
      'about':
          'نحن في "لمسة فنية" نؤمن بأن كل مناسبة تستحق لمسة خاصة. نقدم تصاميم توزيعات مبتكرة وفخمة، مع التركيز على الجودة والتفاصيل الدقيقة.',
      'gallery_images': [
        'assets/p2.jpg', // تأكدي من وجود هذه الصور
        'assets/p2.jpg',
        'assets/p1.jpg',
      ],
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
              'الشوكولاتة خرافية والتغليف أنيق جداً. كانت توزيعات مثالية لمناسبة خطوبتي.',
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
          'في "شمعة أمل"، نركز على تقديم شموع معطرة طبيعية مصنوعة بحب وجودة عالية، لتمنح مناسباتك الدفء والجمال بأسعار مناسبة للجميع.',
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
      ],
    },
  },
];

class DistributionProviderDashboardScreen extends StatefulWidget {
  const DistributionProviderDashboardScreen({super.key});

  @override
  State<DistributionProviderDashboardScreen> createState() =>
      _DistributionProviderDashboardScreenState();
}

class _DistributionProviderDashboardScreenState
    extends State<DistributionProviderDashboardScreen> {
  // هذه الدالة ستُستخدم لتحديث القائمة بعد إضافة/تعديل المتاجر
  void _refreshDistributionStores() {
    // في التطبيق الحقيقي، هنا يتم استدعاء الـ Backend لجلب البيانات المحدثة
    // حالياً، لا نفعل شيئاً لأن البيانات ثابتة (Hardcoded)
    setState(() {
      // فقط لتشغيل إعادة بناء الواجهة إذا تغيرت البيانات (في المستقبل)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم التوزيعات',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body:
          myDistributionStores
                  .isEmpty // عرض رسالة إذا لم يكن هناك متاجر
              ? Center(
                child: Text(
                  'لم يتم إضافة أي متجر توزيعات بعد. اضغط على الزر "+" لإضافة متجرك الأول.',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: myDistributionStores.length,
                itemBuilder: (context, index) {
                  final store = myDistributionStores[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () async {
                        // عند الضغط على المتجر، ننتقل لصفحة الإدارة للتعديل
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ManageDistributionStoreScreen(
                                  distributionStore:
                                      store, // نرسل بيانات المتجر الحالي
                                ),
                          ),
                        );
                        // بعد العودة من صفحة الإدارة (سواء تم تعديل أو حذف)، نقوم بتحديث القائمة
                        _refreshDistributionStores();
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
                                store['main_image'], // الصورة الرئيسية للمتجر
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store['name'],
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    store['description'],
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      Text(
                                        '${store['overall_rating']}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 15,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.local_shipping,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      Text(
                                        store['delivery_available'] == true
                                            ? 'توصيل متاح'
                                            : 'لا يوجد توصيل',
                                        style: GoogleFonts.cairo(
                                          fontSize: 15,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '💰 ${store['price_range']}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // عند الضغط على زر الإضافة، ننتقل لصفحة الإدارة بدون بيانات (لإضافة جديد)
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageDistributionStoreScreen(),
            ),
          );
          // بعد العودة من صفحة الإضافة، نقوم بتحديث القائمة
          _refreshDistributionStores();
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
