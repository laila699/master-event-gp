// lib/screens/vendor_list_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:softwareGP/providers/auth_provider.dart';
import 'package:softwareGP/screens/auth/login_screen.dart';
import 'package:softwareGP/theme/colors.dart';

import '../../models/vendor_filter.dart';
import '../../models/service_type.dart';
import '../../models/user.dart';
import '../../models/provider_attribute.dart';
import '../../providers/vendor_provider.dart';
import 'vendor_details_screen.dart';

/// Which multiSelect keys can we filter by, for each service?
const Map<VendorServiceType, List<String>> _filterKeys = { 
  VendorServiceType.decorator: ['styles', 'eventTypes'],
  VendorServiceType.furnitureStore: ['productCategories'],
  VendorServiceType.photographer: ['photographyTypes', 'eventTypes'],
  VendorServiceType.restaurant: [],
  VendorServiceType.giftShop: ['productTypes'],
  VendorServiceType.entertainer: ['performanceTypes'],
};

/// The available options for each of those keys.
const Map<String, List<String>> _filterOptions = {
  'styles': ['كرفان', 'شاليهات', 'مخيمات', 'فنادق'],
  'eventTypes': [
    'رحل ثقافية',
    'رحلات بحرية',
    'رحلة دينية',
    'رحلة مسارات',
    'رحلة مغامرات',
  ],
  'specialties': ['صالون', 'مطبخ', 'حمام', 'غرف نوم', 'مكاتب'],
  'productCategories': [
    'دراجات نارية',
    ' دراجات هوائية ',
    'سيارات فردية',
    'حافلات صغيرة ',
    'حافلات كبير',
  ],
  'photographyTypes': ['كلاسيكي', ' وثائقي ', 'برومو رحل', 'سينمائي'],
  'productTypes': [
    'إلكترونيات الرحلات',
    'العناية الشخصية',
    'معدات الحمل والتخزين ',
    'ملابس رحلات',
    'مستلزمات طبية',
  ],
  'performanceTypes': [
    ' مرشدين دينيين',
    'تخييم ',
    ' ثقافية وتاريخية',
    'مسارات ومغامرات',
    'مرشدين لغويين ',
  ],
};

/// Friendly display names for each filter key. Labels in Arabic.
const Map<String, String> _filterLabels = {
  'styles': 'انواع الاقامة ',
  'eventTypes': 'نوع الفعالية',
  'specialties': 'التخصصات',
  'productCategories': 'فئات النقل',
  'photographyTypes': 'أسلوب التصوير',
  'productTypes': 'أنواع المعدات',
  'performanceTypes': 'نوع المرشد ',
};

/// Icons for each filter key.
const Map<String, IconData> _filterIcons = {
  'styles': Icons.cabin,
  'eventTypes': Icons.explore,
  'specialties': Icons.design_services,
  'productCategories': Icons.chair,
  'photographyTypes': Icons.camera_alt,
  'productTypes': Icons.hiking,
  'performanceTypes': Icons.explore,
};

class VendorListScreen extends ConsumerStatefulWidget {
  final VendorServiceType initialType;
  const VendorListScreen({Key? key, required this.initialType})
    : super(key: key);

  @override
  ConsumerState<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends ConsumerState<VendorListScreen> {
  late VendorServiceType _selectedType; // نوع الخدمة المحدد
  final Map<String, String> _selectedFilters = {}; // الفلاتر المحددة
  String _searchName = ''; // البحث بالاسم

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override 
  Widget build(BuildContext context) { // بناء نافذة 
    final accent1 = AppColors.gradientStart;
    final accent2 = const Color.fromARGB(255, 244, 168, 196);
    final filter = VendorFilter(
      type: _selectedType, // نوع الخدمة
      attrs: Map.from(_selectedFilters), // الفلاتر المحددة
    );
    final vendorsAsync = ref.watch(vendorListProvider(filter)); //براقب قائمة المزودين مع الفلاتر المحددة

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background radial gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.4,
                colors: [accent1, AppColors.background],
              ),
            ),
          ),
          // Glass blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // AppBar replacement
                Padding(
                  padding: const EdgeInsets.only(
                    top: 48,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'مزودو: ',
                        style: GoogleFonts.orbitron(
                          color: AppColors.textOnNeon,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        _selectedType.label, // اسم الخدمة المحددة
                        style: GoogleFonts.orbitron(
                          color: accent2,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.logout, color: AppColors.error),
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                      ),
                    ],
                  ),
                ),
                // Service-type selector
                SizedBox(
                  height: 60,
                  child: ListView( // إنشاء شريط أفقي لاختيار نوع الخدمة
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children:
                        VendorServiceType.values // استعراض أنواع الخدمات
                            .where((t) => t != VendorServiceType.unknown)
                            .map((type) {
                              final isSelected = type == _selectedType; // تحديد ما إذا كان النوع محددًا
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ChoiceChip(
                                  label: Text(
                                    type.label,
                                    style: GoogleFonts.orbitron(
                                      color:
                                          isSelected
                                              ? AppColors.textOnNeon
                                              : AppColors.textSecondary,
                                    ),
                                  ),
                                  selected: isSelected, // تحديد ما إذا كان النوع محددًا
                                  selectedColor: accent2,
                                  backgroundColor: AppColors.glass,
                                  onSelected: 
                                      (_) => setState(() {  //بمجرد اختيار نوع جديد، يتم تحديث الواجهة فورًا لإظهار البيانات المتعلقة بالنوع الجديد فقط.
                                        _selectedType = type;
                                        _selectedFilters.clear(); // إعادة تعيين الفلاتر المحددة
                                      }),
                                ),
                              );
                            })
                            .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Search & city filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      _buildSearchField( // حقل البحث عن الاسم
                        Icons.search,
                        'ابحث بالاسم',
                        (val) => setState(() => _searchName = val.trim()),
                      ),
                      const SizedBox(height: 8),
                      _buildSearchField( // حقل البحث عن المدينة
                        Icons.location_on,
                        'ابحث بالمدينة',
                        (val) => setState(() {
                          if (val.trim().isEmpty)
                            _selectedFilters.remove('city'); // إذا كانت القيمة فارغة، نزيل المدينة من الفلاتر
                          else
                            _selectedFilters['city'] = val.trim(); // إضافة المدينة إلى الفلاتر
                        }),
                      ),
                    ],
                  ),
                ),
                // Dynamic filters
                if (_filterKeys[_selectedType]!.isNotEmpty) 
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children:
                          _filterKeys[_selectedType]!.expand((key) { // استعراض الفلاتر المتاحة لنوع الخدمة المحدد
                            final options = _filterOptions[key]!;    // الخيارات المتاحة لكل فلتر
                            return [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_filterIcons[key], color: accent2),
                                  const SizedBox(width: 4),
                                  Text(
                                    _filterLabels[key]!, // تسمية الفلتر
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ...options.map((opt) { // إنشاء زر اختيار لكل خيار
                                final selected = _selectedFilters[key] == opt; // تحديد ما إذا كان الخيار محددًا
                                return FilterChip(
                                  label: Text(
                                    opt,
                                    style: GoogleFonts.orbitron(
                                      color:
                                          selected
                                              ? AppColors.textOnNeon // إذا كان الخيار محددًا
                                              : AppColors.textSecondary, // إذا لم يكن محددًا
                                    ),
                                  ),
                                  selected: selected,
                                  selectedColor: accent2,
                                  backgroundColor: AppColors.glass,
                                  onSelected:
                                      (_) => setState(() {
                                        if (selected) // إذا كان الخيار محددًا بالفعل، نقوم بإزالته من الفلاتر
                                          _selectedFilters.remove(key);
                                        else
                                          _selectedFilters[key] = opt; // إضافة الخيار المحدد إلى الفلاتر
                                      }),
                                );
                              }),
                            ];
                          }).toList(),
                    ),
                  ),
                // Vendor list
                Expanded(
                  child: vendorsAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (err, _) => Center(
                          child: Text(
                            'خطأ: $err',
                            style: GoogleFonts.orbitron(color: AppColors.error),
                          ),
                        ),
                    data: (vendors) {
                      final filtered =
                          _searchName.isEmpty // إذا لم يكن هناك بحث بالاسم
                              ? vendors
                              : vendors
                                  .where(
                                    (v) => v.name.toLowerCase().contains( //  نختار فقط المزودين الذين يحتوي اسمهم (v.name)  
                                      _searchName.toLowerCase(), // تحويل اسم البحث إلى أحرف صغيرة
                                    ),
                                  )
                                  .toList();
                      if (filtered.isEmpty) // إذا لم توجد نتائج
                        return Center(
                          child: Text(
                            'لا يوجد نتائج',
                            style: GoogleFonts.orbitron(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      return ListView.builder( // بناء قائمة بالمزودين
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length, // عدد العناصر في القائمة
                        itemBuilder: (_, i) => _VendorCard(vendor: filtered[i]), // نستدعي بطاقة لكل مزود
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField( // بناء حقل البحث قابل لاعادة الاستخدام
    IconData icon,
    String label,
    void Function(String) onChanged, // دالة تعالج التغيير في النص
  ) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 244, 168, 196)),
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.fieldFill, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onChanged: onChanged,
    );
  }
}

class _VendorCard extends StatelessWidget { // بطاقة مزود الخدمة
  final User vendor; // مزود الخدمة بيانات
  const _VendorCard({required this.vendor});  

  @override
  Widget build(BuildContext context) {
    final attrs = vendor.vendorProfile?.attributes ?? <ProviderAttribute>[]; // خصائص المزود
    String city = '—';
    final host = kIsWeb ? 'localhost' : '192.168.1.107';
    final base = 'http://$host:5000/api';
    try { // محاولة الحصول على المدينة من الخصائص
      city = attrs.firstWhere((a) => a.key == 'city').value?.toString() ?? '—';
    } catch (_) {}
    String rating = '-';
    try {
      final ratingVal = 
          vendor.averageRating != null
              ? vendor.averageRating!.toStringAsFixed(1)
              : '-';
      final ratingCount = vendor.ratingsCount ?? 0;
    } catch (_) {}
    final accent2 = const Color.fromARGB(255, 244, 168, 196);

    return Card(
      color: AppColors.glass,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile( //عرض صف في قائمة
        onTap:
            () => Navigator.push( // عند الضغط على البطاقة، ننتقل إلى شاشة تفاصيل المزود
              context,
              MaterialPageRoute(
                builder: (_) => VendorDetailsScreen(vendorId: vendor.id),
              ),
            ),
        leading: CircleAvatar( // صورة المزود
          backgroundImage:
              vendor.avatarUrl != null
                  ? NetworkImage("${base}${vendor.avatarUrl!}")
                  : null,
          child:
              vendor.avatarUrl == null // إذا لم يكن هناك صورة، نعرض أيقونة
                  ? Icon(Icons.person, color: accent2)
                  : null,
        ),
        title: Text(
          vendor.name, // اسم المزود
          style: GoogleFonts.orbitron(
            color: AppColors.textOnNeon,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.textSecondary), // أيقونة الموقع
            const SizedBox(width: 4),
            Text(
              city, // المدينة
              style: GoogleFonts.orbitron(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Icon(Icons.star, size: 16, color: accent2), // أيقونة التقييم
            const SizedBox(width: 4),
            Text(
              vendor.averageRating != null
                  ? vendor.averageRating!.toStringAsFixed(1) 
                  : '-',
              style: GoogleFonts.orbitron(
                color: accent2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${vendor.ratingsCount ?? 0})', // عدد التقييمات
              style: GoogleFonts.orbitron(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
