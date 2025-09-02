// lib/screens/vendor_dashboard/vendor_details_screen.dart

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:softwareGP/providers/auth_provider.dart';
import 'package:softwareGP/providers/chat_provider.dart';
import 'package:softwareGP/screens/chat_screen.dart';
import 'package:softwareGP/screens/vendor_dashboard/menu_tab.dart';
import 'package:softwareGP/screens/vendor_dashboard/offering_tab.dart';
import 'package:softwareGP/theme/colors.dart';

import '../../models/provider_model.dart';
import '../../models/provider_attribute.dart';
import '../../providers/vendor_provider.dart';

class VendorDetailsScreen extends ConsumerStatefulWidget {
  final String vendorId;
  const VendorDetailsScreen({Key? key, required this.vendorId})
    : super(key: key);

  @override
  ConsumerState<VendorDetailsScreen> createState() =>
      _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends ConsumerState<VendorDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // تنظيف موارد tabController
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent1 = AppColors.gradientStart;
    final providerAsync = ref.watch(providerModelFamily(widget.vendorId)); // استدعاء بيانات المزود
    final nameAsync = ref.watch(userNameProvider(widget.vendorId)); // استدعاء اسم المستخدم

    return Scaffold( // هيكل الصفحة
      appBar: AppBar(
        backgroundColor: AppColors.overlay,
        elevation: 0,
        title: nameAsync.when( //  nameAsync ديناميكي يظهر اسم المزود بناء على 
          data: 
              (name) => Text(
                name,
                style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
              ),
          loading:
              () => Text(
                'تحميل...',
                style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
              ),
          error:
              (_, __) => Text(
                'خطأ',
                style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
              ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: accent1, width: 3),
          ),
          tabs: const [
            Tab(text: 'التفاصيل'),
            Tab(text: 'العروض'),
            Tab(text: 'القائمة'),
            Tab(text: 'دردشة'),
          ],
          labelStyle: GoogleFonts.orbitron(
            color: AppColors.textOnNeon,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.orbitron(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: _buildBackground( // بناء خلفية الصفحة
        providerAsync.when( // استدعاء بيانات المزود
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, _) => Center(
                child: Text(
                  'خطأ: $e',
                  style: GoogleFonts.orbitron(color: AppColors.error),
                ),
              ),
          data:
              (provider) => TabBarView( // عرض بيانات المزود في تبويبات
                controller: _tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDetailsTab(provider), // بناء تبويب التفاصيل
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OfferingTab(vendorId: widget.vendorId), // 
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MenuTab(vendorId: widget.vendorId), // بناء تبويب القائمة
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0), // دردشة المزود
                    child: _ChatTab(
                      vendorId: widget.vendorId,
                      vendorName: nameAsync.value ?? 'مقدم', // اسم المزود
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildBackground(Widget child) { // بناء خلفية الصفحة
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.7, -0.7),
              radius: 1.4,
              colors: [AppColors.gradientStart, AppColors.background],
            ),
          ),
        ),
        BackdropFilter( // تأثير ضبابي للخلفية
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: AppColors.overlay),
        ),
        Directionality(textDirection: TextDirection.rtl, child: child),
      ],
    );
  }

  Widget _buildDetailsTab(ProviderModel provider) { //  ProviderModel : obj containing vendor details
    LatLng? vendorLatLng;
    try {
      final locAttr = provider.attributes.firstWhere( // البحث عن خاصية الموقع
        (a) => a.key.toLowerCase() == 'location',
      );
      final map = Map<String, dynamic>.from(locAttr.value as Map); // تحويل القيمة إلى خريطة
      vendorLatLng = LatLng(map['lat'], map['lng']); // إحداثيات الموقع , يستخرج LatLng ,مستخدم في خرائط فلاتر
    } catch (_) {}

    return ListView( // بناء قائمة التفاصيل
      padding: const EdgeInsets.all(16),
      children: [
        if (vendorLatLng != null) ...[ // إذا كان هناك إحداثيات للموقع يعرض خريطة
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap( // استخدام مكتبة FlutterMap لعرض الخريطة
                options: MapOptions(
                  initialCenter: vendorLatLng, //تحديد مركز الخريطة على موقع المزود
                  initialZoom: 15, // مستوى تكبير الخريطة
                ),
                children: [
                  if (provider.averageRating != null) ...[ // إذا كان هناك تقييم للمزود
                    Row( 
                      children: [
                        Icon(
                          Icons.star,
                          color: const Color.fromARGB(255, 244, 168, 196),
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.averageRating!.toStringAsFixed(1), // تنسيق التقييم ليظهر برقم عشري واحد
                          style: GoogleFonts.orbitron(
                            color: AppColors.textOnNeon,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (provider.ratingsCount != null &&  // هناك عدد تقييمات غير فارغ (null) وعدده أكبر من صفر.
                            provider.ratingsCount! > 0) ...[ 
                          const SizedBox(width: 4),
                          Text(
                            '(${provider.ratingsCount})', // عدد التقييمات
                            style: GoogleFonts.orbitron(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  TileLayer(  //يقوم بجلب خريطة بلاطات (tiles) من خدمة OpenStreetMap باستخدام الرابط urlTemplate.

                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', // استخدام خريطة OpenStreetMap
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: vendorLatLng,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          size: 32,
                          color: const Color.fromARGB(255, 244, 168, 196),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...provider.attributes // بضيف العناصر مباشرة داخل list view
            .where((a) => a.key.toLowerCase() != 'location') // استبعاد خاصية الموقع
            .map(_buildAttributeCard),
      ],
    );
  }

  Widget _buildAttributeCard(ProviderAttribute attr) {  // بناء بطاقة لعرض  الخصائص الاخرى
    final value = attr.value; // تمثل خاصية من خصائص المزود

    bool _isImagePath(String v) { // التحقق مما إذا كانت النص تمثل مسار صورة
      return v.endsWith('.png') || // صيغ صور
          v.endsWith('.jpg') ||
          v.endsWith('.jpeg') ||
          v.endsWith('.webp');
    }

    List<String> _extractImagePaths(dynamic value) {
      if (value is List) {
        return value.whereType<String>().where(_isImagePath).toList();
      }
      return [];
    }

    final images = _extractImagePaths(value); // استخراج مسارات الصور
    final host = kIsWeb ? 'localhost' : '192.168.1.107';
    final base = 'http://$host:5000/api'; // عنوان السيرفر للوصول للبيانات
    return Card( // بطاقة تحتوي على خاصية المزود
      color: AppColors.glass,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attr.label ?? '', // عنوان الخاصية
              style: GoogleFonts.orbitron(
                color: AppColors.textOnNeon,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (images.isNotEmpty)
              SizedBox( // عرض الصور في شريط أفقي
                height: 100,
                child: ListView.separated( // إنشاء شريط أفقي للصور
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) { // بناء عنصر الصورة
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network( // تحميل الصورة من الإنترنت
                        '${base}${images[i]}',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container( // في حالة حدوث خطأ في تحميل الصورة
                              color: Colors.black26,
                              width: 100,
                              height: 100,
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    );
                  },
                ),
              )
            else
              Text(
                value?.toString() ?? '-',
                style: GoogleFonts.orbitron(color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatTab extends ConsumerWidget { // تبويب الدردشة
  final String vendorId;
  final String vendorName;
  const _ChatTab({required this.vendorId, required this.vendorName}); // معرف المزود واسم المزود

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdAsync = ref.watch(createChatProvider(vendorId)); //     لاستدعاء مزود الحالة الذي ينشئ أو يسترجع معرّف الدردشة (chatId) بين المستخدم الحالي والمزود
    return chatIdAsync.when(
      data:
          (chatId) => ChatScreen(
            chatId: chatId,
            otherUid: vendorId,
            otherName: vendorName,
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => Center(
            child: Text(
              'خطأ في الدردشة: $e',
              style: GoogleFonts.orbitron(color: AppColors.error),
            ),
          ),
    );
  }
}
