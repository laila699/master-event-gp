// lib/screens/event_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:masterevent/EventBudgetPage.dart';
import 'package:masterevent/EventLogisticsPage.dart';
import 'package:masterevent/EventReviewsPage.dart';
import 'package:masterevent/EventToDoListPage.dart';
import 'package:masterevent/screens/booking_Details_Card.dart';
import '../providers/event_provider.dart';
import '../providers/booking_provider.dart';
import '../models/event.dart';
import '../screens/guest_tab.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  bool _isEditing = false;

  // controllers for editing
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _venueController;
  LatLng? _editLocation;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _dateController = TextEditingController();
    _venueController = TextEditingController();
    _tabController = TabController(length: 4, vsync: this);
    _mapController = MapController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _enterEditMode(Event event) async {
    _titleController.text = event.title;
    _dateController.text = event.date.toIso8601String().split('T').first;
    _venueController.text = event.venue;
    _editLocation = event.venueLocation;
    setState(() => _isEditing = true);
    if (_editLocation != null) {
      _mapController.move(_editLocation!, 13);
    }
  }

  Future<void> _locateUser() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() => _editLocation = latlng);
      _mapController.move(latlng, 13);
    } catch (e) {
      // ignore or show a message
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'اختر تاريخ المناسبة',
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.purple,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      _dateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _saveChanges() async {
    final svc = ref.read(eventServiceProvider);
    await svc.updateEvent(
      eventId: widget.eventId,
      title: _titleController.text.trim(),
      date: DateTime.parse(_dateController.text.trim()),
      venue: _venueController.text.trim(),
      venueLocation: _editLocation,
    );
    ref.invalidate(eventDetailProvider(widget.eventId));
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final evAsync = ref.watch(eventDetailProvider(widget.eventId));
    final primary = Colors.purple;
    final theme = Theme.of(context).copyWith(
      textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        titleTextStyle: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: const Color.fromARGB(255, 68, 55, 55),
        unselectedLabelColor: const Color.fromARGB(179, 97, 79, 79),
        labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل المناسبة'),
            actions: [
              IconButton(
                icon: const Icon(Icons.my_location),
                tooltip: 'تحديد موقعي',
                onPressed: _locateUser,
              ),
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'تعديل',
                  onPressed: () => evAsync.whenData(_enterEditMode),
                ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'حفظ',
                  onPressed: _saveChanges,
                ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                tooltip: 'حذف المناسبة',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('تأكيد الحذف'),
                          content: const Text('هل تريد حذف هذه المناسبة؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await ref.read(
                                  deleteEventProvider(widget.eventId).future,
                                );
                                ref.invalidate(eventListProvider);
                                if (!mounted) return;
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'التفاصيل'),
                Tab(text: 'الحجوزات'),
                Tab(text: 'الضيوف'),
                Tab(text: 'الإعدادات'),
              ],
            ),
          ),
          body: evAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, _) => Center(
                  child: Text(
                    'خطأ: \$err',
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                ),
            data: (event) {
              return TabBarView(
                controller: _tabController,
                children: [
                  // DETAILS TAB
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child:
                        _isEditing
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'اسم المناسبة',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: 'تاريخ المناسبة',
                                    border: OutlineInputBorder(),
                                  ),
                                  onTap: () => _selectDate(context),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _venueController,
                                  decoration: const InputDecoration(
                                    labelText: 'مكان المناسبة',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 200,
                                  child: FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter:
                                          _editLocation ??
                                          LatLng(34.7136, 46.6753),
                                      initialZoom: 13,
                                      onTap: (_, p) {
                                        setState(() => _editLocation = p);
                                        _mapController.move(p, 13);
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        subdomains: const ['a', 'b', 'c'],
                                      ),
                                      if (_editLocation != null)
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              width: 40,
                                              height: 40,
                                              point: _editLocation!,
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: _saveChanges,
                                  icon: const Icon(Icons.save),
                                  label: const Text('حفظ التعديلات'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '📅 ${_formatDate(event.date)}',
                                  style: GoogleFonts.cairo(),
                                ),
                                Text(
                                  '📍 ${event.venue}',
                                  style: GoogleFonts.cairo(),
                                ),
                                const SizedBox(height: 12),
                                if (event.venueLocation != null)
                                  SizedBox(
                                    height: 200,
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: event.venueLocation!,
                                        initialZoom: 13,
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
                                              width: 36,
                                              height: 36,
                                              point: event.venueLocation!,
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 36,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                  ),
                  // BOOKINGS TAB
                  Consumer(
                    builder: (ctx, ref, _) {
                      final bAsync = ref.watch(
                        eventBookingDetailsProvider(widget.eventId),
                      );
                      return bAsync.when(
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (e, _) => Center(
                              child: Text(
                                'خطأ في تحميل الحجوزات: \$e',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                        data:
                            (bookings) =>
                                bookings.isEmpty
                                    ? Center(
                                      child: Text(
                                        'لا توجد حجوزات لهذه المناسبة',
                                        style: GoogleFonts.cairo(fontSize: 16),
                                      ),
                                    )
                                    : ListView.builder(
                                      itemCount: bookings.length,
                                      itemBuilder: (context, index) {
                                        return BookingDetailCard(
                                          booking: bookings[index],
                                        );
                                      },
                                    ),
                      );
                    },
                  ),
                  // GUESTS TAB
                  GuestTab(eventId: widget.eventId),
                  // SETTINGS TAB
                  ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) {
                      final items = [
                        {
                          'title': 'الميزانية والتكلفة',
                          'icon': Icons.attach_money,
                          'page': EventBudgetPage(eventId: event.id),
                        },
                        {
                          'title': 'الترتيبات اللوجستية',
                          'icon': Icons.local_shipping,
                          'page': EventLogisticsPage(eventId: event.id),
                        },
                        {
                          'title': 'تنظيم المهام',
                          'icon': Icons.checklist_rtl,
                          'page': EventToDoListPage(eventId: event.id),
                        },
                        {
                          'title': 'المراجعات والتقييمات',
                          'icon': Icons.star_rate,
                          'page': EventReviewsPage(),
                        },
                      ];
                      final it = items[i];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            it['icon'] as IconData,
                            color: Colors.purple.shade700,
                          ),
                          title: Text(
                            it['title'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => it['page'] as Widget,
                                ),
                              ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
