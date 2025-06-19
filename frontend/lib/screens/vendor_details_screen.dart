// lib/screens/vendor_dashboard/vendor_details_screen.dart

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:masterevent/providers/auth_provider.dart';
import 'package:masterevent/providers/chat_provider.dart';
import 'package:masterevent/screens/chat_screen.dart';
import 'package:masterevent/screens/vendor_dashboard/menu_tab.dart';
import 'package:masterevent/screens/vendor_dashboard/offering_tab.dart';
import 'package:masterevent/theme/colors.dart';

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent1 = AppColors.gradientStart;
    final providerAsync = ref.watch(providerModelFamily(widget.vendorId));
    final nameAsync = ref.watch(userNameProvider(widget.vendorId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.overlay,
        elevation: 0,
        title: nameAsync.when(
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
      body: _buildBackground(
        providerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, _) => Center(
                child: Text(
                  'خطأ: $e',
                  style: GoogleFonts.orbitron(color: AppColors.error),
                ),
              ),
          data:
              (provider) => TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDetailsTab(provider),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OfferingTab(vendorId: widget.vendorId),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MenuTab(vendorId: widget.vendorId),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _ChatTab(
                      vendorId: widget.vendorId,
                      vendorName: nameAsync.value ?? 'مقدم',
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildBackground(Widget child) {
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
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: AppColors.overlay),
        ),
        Directionality(textDirection: TextDirection.rtl, child: child),
      ],
    );
  }

  Widget _buildDetailsTab(ProviderModel provider) {
    LatLng? vendorLatLng;
    try {
      final locAttr = provider.attributes.firstWhere(
        (a) => a.key.toLowerCase() == 'location',
      );
      final map = Map<String, dynamic>.from(locAttr.value as Map);
      vendorLatLng = LatLng(map['lat'], map['lng']);
    } catch (_) {}

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vendorLatLng != null) ...[
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: vendorLatLng,
                  initialZoom: 15,
                ),
                children: [
                  if (provider.averageRating != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.gradientEnd,
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.averageRating!.toStringAsFixed(1),
                          style: GoogleFonts.orbitron(
                            color: AppColors.textOnNeon,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (provider.ratingsCount != null &&
                            provider.ratingsCount! > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${provider.ratingsCount})',
                            style: GoogleFonts.orbitron(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                          color: AppColors.gradientEnd,
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
        ...provider.attributes
            .where((a) => a.key.toLowerCase() != 'location')
            .map(_buildAttributeCard),
      ],
    );
  }

  Widget _buildAttributeCard(ProviderAttribute attr) {
    final value = attr.value;

    bool _isImagePath(String v) {
      return v.endsWith('.png') ||
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

    final images = _extractImagePaths(value);
    final host = kIsWeb ? 'localhost' : '192.168.1.122';
    final base = 'http://$host:5000/api';
    return Card(
      color: AppColors.glass,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attr.label ?? '',
              style: GoogleFonts.orbitron(
                color: AppColors.textOnNeon,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '${base}${images[i]}',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
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

class _ChatTab extends ConsumerWidget {
  final String vendorId;
  final String vendorName;
  const _ChatTab({required this.vendorId, required this.vendorName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdAsync = ref.watch(createChatProvider(vendorId));
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
