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
    final providerAsync = ref.watch(providerModelFamily(widget.vendorId));
    final nameAsync = ref.watch(userNameProvider(widget.vendorId));
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل المزود', style: GoogleFonts.cairo()),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(child: Text('التفاصيل', style: TextStyle(color: Colors.white))),
            Tab(child: Text('العروض', style: TextStyle(color: Colors.white))),
            Tab(child: Text('القائمة', style: TextStyle(color: Colors.white))),
            Tab(child: Text('دردشة', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
      body: providerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(
              child: Text(
                'خطأ: $e',
                style: GoogleFonts.cairo(color: Colors.red),
              ),
            ),
        data: (provider) {
          // Extract vendor location
          LatLng? vendorLatLng;
          try {
            final locAttr = provider.attributes.firstWhere(
              (a) => a.key.toLowerCase() == 'location',
            );
            final locMap = Map<String, dynamic>.from(locAttr.value as Map);
            vendorLatLng = LatLng(
              (locMap['lat'] as num).toDouble(),
              (locMap['lng'] as num).toDouble(),
            );
          } catch (_) {
            vendorLatLng = null;
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // DETAILS
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (vendorLatLng != null) ...[
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: vendorLatLng,
                          initialZoom: 15,
                        ),
                        children: [
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
                                child: const Icon(
                                  Icons.location_on,
                                  size: 32,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Other attributes
                  ...provider.attributes
                      .where((a) => a.key.toLowerCase() != 'location')
                      .map((attr) => _buildAttributeCard(attr)),
                ],
              ),

              // OFFERINGS
              OfferingTab(vendorId: widget.vendorId),

              // MENU
              MenuTab(vendorId: widget.vendorId),

              // CHAT
              _ChatTab(
                vendorId: widget.vendorId,
                vendorName: nameAsync.when(
                  data: (data) => data,
                  loading: () => '...',
                  error: (_, __) => '??',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttributeCard(ProviderAttribute attr) {
    // ... unchanged ...
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attr.label ?? '',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(attr.value?.toString() ?? '-'),
          ],
        ),
      ),
    );
  }
}

/// ChatTab: opens or creates a 1:1 chat with the vendor
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
      error: (e, _) => Center(child: Text('خطأ في الدردشة: $e')),
    );
  }
}
