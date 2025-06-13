import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final filter = VendorFilter(
      type: _selectedType,
      attrs: Map.from(_selectedFilters),
    );
    final vendorsAsync = ref.watch(vendorListProvider(filter));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(
            'مزودو: ${_selectedType.label}',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Service‐type selector ──
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
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(type.label),
                              selected: isSelected,
                              selectedColor: Colors.purple,
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

            // ── Search by name ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  labelText: 'ابحث بالاسم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                onChanged:
                    (val) => setState(() {
                      _searchName = val.trim();
                    }),
              ),
            ),

            // ── City text-filter ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on),
                  labelText: 'ابحث بالمدينة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                onChanged:
                    (val) => setState(() {
                      if (val.trim().isEmpty) {
                        _selectedFilters.remove('city');
                      } else {
                        _selectedFilters['city'] = val.trim();
                      }
                    }),
              ),
            ),

            // ── Dynamic multiSelect filters ──
            if (_filterKeys[_selectedType]!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      _filterKeys[_selectedType]!.map((key) {
                        final options = _filterOptions[key]!;
                        final label = _filterLabels[key] ?? key;
                        final icon = _filterIcons[key] ?? Icons.filter_list;

                        return Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 20, color: Colors.purple),
                                const SizedBox(width: 4),
                                Text(
                                  label,
                                  style: GoogleFonts.cairo(
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
                                  style: GoogleFonts.cairo(
                                    color:
                                        selected ? Colors.white : Colors.black,
                                  ),
                                ),
                                selected: selected,
                                selectedColor: Colors.purple,
                                onSelected:
                                    (_) => setState(() {
                                      if (selected) {
                                        _selectedFilters.remove(key);
                                      } else {
                                        _selectedFilters[key] = opt;
                                      }
                                    }),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                ),
              ),

            // ── The vendor list ──
            Expanded(
              child: vendorsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, _) => Center(
                      child: Text(
                        'خطأ: ${err.toString()}',
                        style: GoogleFonts.cairo(color: Colors.red),
                      ),
                    ),
                data: (vendors) {
                  // apply client-side name search
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

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text('لا يوجد نتائج', style: GoogleFonts.cairo()),
                    );
                  }
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
    try {
      city = attrs.firstWhere((a) => a.key == 'city').value?.toString() ?? '—';
    } catch (_) {}

    String rating = '-';
    try {
      rating =
          attrs.firstWhere((a) => a.key == 'rating').value?.toString() ?? '-';
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
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
              vendor.avatarUrl != null ? NetworkImage(vendor.avatarUrl!) : null,
          child: vendor.avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          vendor.name,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(city, style: GoogleFonts.cairo()),
            const SizedBox(width: 12),
            Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(rating, style: GoogleFonts.cairo()),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
