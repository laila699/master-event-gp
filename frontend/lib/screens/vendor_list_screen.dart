// lib/screens/vendor_list_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/providers/auth_provider.dart';
import 'package:masterevent/screens/auth/login_screen.dart';
import 'package:masterevent/theme/colors.dart';

import '../../models/vendor_filter.dart';
import '../../models/service_type.dart';
import '../../models/user.dart';
import '../../models/provider_attribute.dart';
import '../../providers/vendor_provider.dart';
import 'vendor_details_screen.dart';

/// Which multiSelect keys can we filter by, for each service?
const Map<VendorServiceType, List<String>> _filterKeys = {
  VendorServiceType.decorator: ['styles', 'eventTypes'],
  VendorServiceType.interiorDesigner: ['specialties'],
  VendorServiceType.furnitureStore: ['productCategories'],
  VendorServiceType.photographer: ['photographyTypes', 'eventTypes'],
  VendorServiceType.restaurant: [],
  VendorServiceType.giftShop: ['productTypes'],
  VendorServiceType.entertainer: ['performanceTypes'],
};

/// The available options for each of those keys.
const Map<String, List<String>> _filterOptions = {
  'styles': ['كلاسيكي', 'حديث', 'ريفي', 'صناعي', 'مزيج'],
  'eventTypes': ['زفاف', 'خطوبة', 'تخرج', 'عيد ميلاد', 'حفل عمل'],
  'specialties': ['صالون', 'مطبخ', 'حمام', 'غرف نوم', 'مكاتب'],
  'productCategories': ['كراسي', 'طاولات', 'كنب', 'أسرة', 'خزائن'],
  'photographyTypes': ['كلاسيكي', 'سينمائي', 'استوديو', 'خارجي'],
  'productTypes': ['ساعات', 'عطور', 'إكسسوارات', 'شوكولاتة', 'زهور'],
  'performanceTypes': ['دي جي', 'مغني', 'فرقة موسيقية', 'ساحر', 'مهرج'],
};

/// Friendly display names for each filter key.
const Map<String, String> _filterLabels = {
  'styles': 'أنماط الديكور',
  'eventTypes': 'نوع الفعالية',
  'specialties': 'التخصصات',
  'productCategories': 'فئات المنتج',
  'photographyTypes': 'أسلوب التصوير',
  'productTypes': 'أنواع الهدايا',
  'performanceTypes': 'أنواع العرض',
};

/// Icons for each filter key.
const Map<String, IconData> _filterIcons = {
  'styles': Icons.brush,
  'eventTypes': Icons.event,
  'specialties': Icons.design_services,
  'productCategories': Icons.chair,
  'photographyTypes': Icons.camera_alt,
  'productTypes': Icons.card_giftcard,
  'performanceTypes': Icons.music_note,
};

class VendorListScreen extends ConsumerStatefulWidget {
  final VendorServiceType initialType;
  const VendorListScreen({Key? key, required this.initialType})
    : super(key: key);

  @override
  ConsumerState<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends ConsumerState<VendorListScreen> {
  late VendorServiceType _selectedType;
  final Map<String, String> _selectedFilters = {};
  String _searchName = '';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    final accent1 = AppColors.gradientStart;
    final accent2 = AppColors.gradientEnd;
    final filter = VendorFilter(
      type: _selectedType,
      attrs: Map.from(_selectedFilters),
    );
    final vendorsAsync = ref.watch(vendorListProvider(filter));

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
                        _selectedType.label,
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
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children:
                        VendorServiceType.values
                            .where((t) => t != VendorServiceType.unknown)
                            .map((type) {
                              final isSelected = type == _selectedType;
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
                                  selected: isSelected,
                                  selectedColor: accent2,
                                  backgroundColor: AppColors.glass,
                                  onSelected:
                                      (_) => setState(() {
                                        _selectedType = type;
                                        _selectedFilters.clear();
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
                      _buildSearchField(
                        Icons.search,
                        'ابحث بالاسم',
                        (val) => setState(() => _searchName = val.trim()),
                      ),
                      const SizedBox(height: 8),
                      _buildSearchField(
                        Icons.location_on,
                        'ابحث بالمدينة',
                        (val) => setState(() {
                          if (val.trim().isEmpty)
                            _selectedFilters.remove('city');
                          else
                            _selectedFilters['city'] = val.trim();
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
                          _filterKeys[_selectedType]!.expand((key) {
                            final options = _filterOptions[key]!;
                            return [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_filterIcons[key], color: accent2),
                                  const SizedBox(width: 4),
                                  Text(
                                    _filterLabels[key]!,
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ...options.map((opt) {
                                final selected = _selectedFilters[key] == opt;
                                return FilterChip(
                                  label: Text(
                                    opt,
                                    style: GoogleFonts.orbitron(
                                      color:
                                          selected
                                              ? AppColors.textOnNeon
                                              : AppColors.textSecondary,
                                    ),
                                  ),
                                  selected: selected,
                                  selectedColor: accent2,
                                  backgroundColor: AppColors.glass,
                                  onSelected:
                                      (_) => setState(() {
                                        if (selected)
                                          _selectedFilters.remove(key);
                                        else
                                          _selectedFilters[key] = opt;
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
                          _searchName.isEmpty
                              ? vendors
                              : vendors
                                  .where(
                                    (v) => v.name.toLowerCase().contains(
                                      _searchName.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                      if (filtered.isEmpty)
                        return Center(
                          child: Text(
                            'لا يوجد نتائج',
                            style: GoogleFonts.orbitron(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _VendorCard(vendor: filtered[i]),
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

  Widget _buildSearchField(
    IconData icon,
    String label,
    void Function(String) onChanged,
  ) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.gradientEnd),
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

class _VendorCard extends StatelessWidget {
  final User vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final attrs = vendor.vendorProfile?.attributes ?? <ProviderAttribute>[];
    String city = '—';
    final host = kIsWeb ? 'localhost' : '192.168.1.122';
    final base = 'http://$host:5000/api';
    try {
      city = attrs.firstWhere((a) => a.key == 'city').value?.toString() ?? '—';
    } catch (_) {}
    String rating = '-';
    try {
      rating =
          attrs.firstWhere((a) => a.key == 'rating').value?.toString() ?? '-';
    } catch (_) {}
    final accent2 = AppColors.gradientEnd;

    return Card(
      color: AppColors.glass,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VendorDetailsScreen(vendorId: vendor.id),
              ),
            ),
        leading: CircleAvatar(
          backgroundImage:
              vendor.avatarUrl != null
                  ? NetworkImage("${base}${vendor.avatarUrl!}")
                  : null,
          child:
              vendor.avatarUrl == null
                  ? Icon(Icons.person, color: accent2)
                  : null,
        ),
        title: Text(
          vendor.name,
          style: GoogleFonts.orbitron(
            color: AppColors.textOnNeon,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              city,
              style: GoogleFonts.orbitron(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Icon(Icons.star, size: 16, color: accent2),
            const SizedBox(width: 4),
            Text(
              rating,
              style: GoogleFonts.orbitron(color: AppColors.textSecondary),
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
