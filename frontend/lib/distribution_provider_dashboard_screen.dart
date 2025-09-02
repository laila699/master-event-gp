// lib/distribution_provider_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:softwareGP/manage_Distribution_Store_screen.dart';

// **ملاحظة:** في التطبيق الحقيقي، هذه القائمة ستأتي من الـ Backend
// لكن لأغراض الـ Front-end، سنستخدم هذه البيانات كمثال
final List<Map<String, dynamic>> myDistributionStores = [
  {
    'id': 'store_A',
    'name': 'لمسة فنية للمعدات',
    'description': 'نصمم معدات مبتكرة لكل رحلة، بلمسة إبداعية خاصة.',
    'main_image': 'assets/p1.jpg', // تأكدي من وجود هذه الصورة
    'price_range': 'تبدأ من 7 شيكل',
    'overall_rating': 4.7,
    'delivery_available': true,
    'event_types_covered': [
      'رحلة مسارات',
      'رحلة بحرية',
      'رحلة جبلية',
      'رحلة مغامرات',
      'رحلة تخييم',
    ],
    'distribution_types_offered': ['خيم مغلقة', 'أدوات إضاءة', 'معدات خاصة'],
    'details': {
      'about':
          'نحن في "لمسة فنية" نؤمن بأن كل رحلة تستحق معدات مميزة. نقدم تصاميم مبتكرة وعملية مع التركيز على الجودة والتفاصيل الدقيقة.',
      'gallery_images': ['assets/p2.jpg', 'assets/p2.jpg', 'assets/p1.jpg'],
      'specific_distributions': [
        {
          'name': 'حقيبة معدات الرحلات',
          'image': 'assets/p1.jpg',
          'price': '8 شيكل/حبة',
          'components': 'حقيبة مقاومة للماء، أدوات أساسية، حبال متينة',
          'suitable_for': ['رحلة مسارات', 'رحلة بحرية'],
          'is_customizable': true,
        },
        {
          'name': 'عدة التخييم',
          'image': 'assets/p1.jpg',
          'price': '18 شيكل/حقيبة',
          'components': 'مصباح، بوصلة، علبة كبريت، سكين متعدد الاستخدام',
          'suitable_for': ['رحلة تخييم', 'رحلة جبلية'],
          'is_customizable': false,
        },
      ],
      'customer_reviews': [
        {
          'user': 'Sara K.',
          'rating': 5,
          'comment': 'معداتهم عملية وجودتها ممتازة! أنصح بها للرحلات.',
        },
        {
          'user': 'Ahmad M.',
          'rating': 4,
          'comment': 'خدمة رائعة، لكن التوصيل أخذ وقت أطول من المتوقع.',
        },
      ],
    },
  },
  {
    'id': 'store_B',
    'name': 'روائع الحقائب',
    'description': 'حقائبنا الصغيرة عملية وخفيفة لجميع الرحلات.',
    'main_image': 'assets/p2.jpg',
    'price_range': 'تبدأ من 12 شيكل',
    'overall_rating': 4.5,
    'delivery_available': false,
    'event_types_covered': ['رحلة بحرية', 'رحلة عائلية', 'رحلة خاصة'],
    'distribution_types_offered': ['حقائب صغيرة', 'حقائب مقاومة للماء'],
    'details': {
      'about':
          'في "روائع الحقائب"، نقدم حقائب مخصصة للرحلات بجودة عالية لتسهل حمل الأغراض وتوفر الراحة خلال السفر والمغامرات.',
      'gallery_images': ['assets/p1.jpg', 'assets/p1.jpg'],
      'specific_distributions': [
        {
          'name': 'حقيبة ظهر للرحلات',
          'image': 'assets/p2.jpg',
          'price': '15 شيكل/حقيبة',
          'components': 'حقيبة ضد الماء، جيوب متعددة، تصميم مريح للظهر',
          'suitable_for': ['رحلة جبلية', 'رحلة بحرية'],
          'is_customizable': true,
        },
      ],
      'customer_reviews': [
        {
          'user': 'Layla H.',
          'rating': 5,
          'comment': 'الحقائب خفيفة وسهلة الاستخدام. ممتازة للرحلات الطويلة.',
        },
      ],
    },
  },
  {
    'id': 'store_C',
    'name': 'معدات الأمل',
    'description': 'متخصصون في معدات التخييم والرحلات الجبلية.',
    'main_image': 'assets/s1.jpg',
    'price_range': 'تبدأ من 5 شيكل',
    'overall_rating': 4.9,
    'delivery_available': true,
    'event_types_covered': ['رحلة جبلية', 'رحلة مسارات', 'رحلة تخييم'],
    'distribution_types_offered': ['خيم مخصصة', 'مستلزمات تخييم'],
    'details': {
      'about':
          'في "معدات الأمل" نوفر جميع مستلزمات التخييم والرحلات بأعلى جودة لتجعل مغامرتك أكثر أماناً وراحة.',
      'gallery_images': ['assets/s2.jpg', 'assets/s2.jpg', 'assets/s1.jpg'],
      'specific_distributions': [
        {
          'name': 'خيمة التخييم المقاومة للمطر',
          'image': 'assets/s1.jpg',
          'price': '7 شيكل/خيمة',
          'components': 'خامة مقاومة للمطر، أعمدة متينة، فتحات تهوية',
          'suitable_for': ['رحلة تخييم', 'رحلة جبلية'],
          'is_customizable': true,
        },
        {
          'name': 'عدة النوم في التخييم',
          'image': 'assets/p1.jpg',
          'price': '5 شيكل/عدة',
          'components': 'فرشة خفيفة، sleeping bag، وسادة هوائية',
          'suitable_for': ['رحلة تخييم'],
          'is_customizable': false,
        },
      ],
      'customer_reviews': [
        {
          'user': 'Reem F.',
          'rating': 5,
          'comment': 'الخيم ممتازة وسهلة التركيب. تجربة رائعة للتخييم.',
        },
      ],
    },
  },
  {
    'id': 'store_D',
    'name': 'إضاءة الرحلات',
    'description': 'نوفر شموع وإضاءة محمولة مثالية لأجواء التخييم.',
    'main_image': 'assets/s1.jpg',
    'price_range': 'تبدأ من 10 شيكل',
    'overall_rating': 4.2,
    'delivery_available': true,
    'event_types_covered': ['رحلة تخييم', 'رحلة جبلية', 'رحلة ليلية'],
    'distribution_types_offered': ['شموع للرحلات', 'إضاءة محمولة'],
    'details': {
      'about':
          'في "إضاءة الرحلات"، نركز على توفير وسائل إنارة آمنة ومحمولة لتجعل الليالي في الرحلات والتخييم أكثر راحة وأماناً.',
      'gallery_images': ['assets/s1.jpg', 'assets/s2.jpg'],
      'specific_distributions': [
        {
          'name': 'شموع التخييم المعطرة',
          'image': 'assets/s1.jpg',
          'price': '12 شيكل/شمعة',
          'components': 'شمع صويا، عطر طبيعي، علبة معدنية صغيرة',
          'suitable_for': ['رحلة تخييم', 'رحلة جبلية'],
          'is_customizable': true,
        },
        {
          'name': 'مصباح يدوي محمول',
          'image': 'assets/p2.jpg',
          'price': '10 شيكل/مصباح',
          'components': 'إضاءة LED قوية، بطارية طويلة الأمد، تصميم مضاد للماء',
          'suitable_for': ['رحلة ليلية', 'رحلة بحرية'],
          'is_customizable': false,
        },
      ],
      'customer_reviews': [
        {
          'user': 'Sami K.',
          'rating': 4,
          'comment': 'الإضاءة ممتازة وسهلة الحمل. مناسبة جداً للتخييم.',
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
          'لوحة تحكم المعدات',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 244, 168, 196),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body:
          myDistributionStores
                  .isEmpty // عرض رسالة إذا لم يكن هناك متاجر
              ? Center(
                child: Text(
                  'لم يتم إضافة أي متجر معدات بعد. اضغط على الزر "+" لإضافة متجرك الأول.',
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
        backgroundColor: const Color.fromARGB(255, 244, 168, 196),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
