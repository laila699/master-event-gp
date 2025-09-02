// lib/screens/event_details_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:softwareGP/TripBudgetPage.dart';
import 'package:softwareGP/TripLogisticsPage.dart';
import 'package:softwareGP/TripReviewsPage.dart';
import 'package:softwareGP/TripToDoListPage.dart';
import 'package:softwareGP/screens/booking_Details_Card.dart';
import 'package:softwareGP/theme/colors.dart';
import '../providers/tr_provider.dart';
import '../providers/booking_provider.dart';
import '../models/trip.dart';
import 'member_tab.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  final String eventId;
  const TripDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen>
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

  Future<void> _enterEditMode(Trip event) async {
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
    } catch (_) {}
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.gradientStart,
                onPrimary: AppColors.textOnNeon,
                surface: AppColors.glass,
                onSurface: AppColors.textOnNeon,
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
    await svc.updateTrip(
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

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.8, -0.8),
              radius: 1.5,
              colors: [AppColors.gradientStart, AppColors.background],
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(color: AppColors.overlay),
        ),
        Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: Colors.transparent,
            textTheme: GoogleFonts.orbitronTextTheme(),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.glass.withOpacity(0.4),
              elevation: 0,
              titleTextStyle: GoogleFonts.orbitron(
                color: AppColors.textOnNeon,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
              iconTheme: IconThemeData(color: AppColors.textOnNeon),
            ),
            tabBarTheme: TabBarThemeData(
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gradientStart,
                    const Color.fromARGB(255, 244, 168, 196),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: AppColors.textOnNeon,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.orbitron(fontWeight: FontWeight.w600),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('تفاصيل الرحلة'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _locateUser,
                ),
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => evAsync.whenData(_enterEditMode),
                  ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveChanges,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            backgroundColor: AppColors.glass,
                            title: const Text('تأكيد الحذف'),
                            content: const Text('هل تريد حذف هذه الرحلة ؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await ref.read(
                                    deleteTripProvider(widget.eventId).future,
                                  );
                                  ref.invalidate(eventListProvider);
                                  if (mounted) Navigator.pop(context);
                                },
                                child: const Text(
                                  'حذف',
                                  style: TextStyle(color: AppColors.error),
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
                  Tab(text: 'المشاركين'),
                  Tab(text: 'الإعدادات'),
                ],
              ),
            ),
            body: evAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, _) => Center(
                    child: Text(
                      'خطأ: $err',
                      style: GoogleFonts.orbitron(color: AppColors.error),
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
                              ? _buildEditForm()
                              : _buildDetailView(event),
                    ),
                    // BOOKINGS
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
                                  'خطأ في تحميل الحجوزات: $e',
                                  style: GoogleFonts.orbitron(),
                                ),
                              ),
                          data:
                              (bookings) =>
                                  bookings.isEmpty
                                      ? Center(
                                        child: Text(
                                          'لا توجد حجوزات لهذه الرحلة',
                                          style: GoogleFonts.orbitron(),
                                        ),
                                      )
                                      : ListView.builder(
                                        itemCount: bookings.length,
                                        itemBuilder:
                                            (context, i) => BookingDetailCard(
                                              booking: bookings[i],
                                              eventId: widget.eventId,
                                            ),
                                      ),
                        );
                      },
                    ),
                    // GUESTS TAB
                    MemberTab(eventId: widget.eventId),
                    // SETTINGS TAB
                    _buildSettingsList(context, event),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(_titleController, 'اسم الرحلة'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(child: _field(_dateController, 'تاريخ الرحلة')),
        ),
        const SizedBox(height: 12),
        _field(_venueController, 'مكان الرحلة'),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _editLocation ?? LatLng(24.7136, 46.6753),
              initialZoom: 13,
              onTap: (_, p) => setState(() => _editLocation = p),
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
                      point: _editLocation!,
                      width: 40,
                      height: 40,
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
          icon: const Icon(Icons.save),
          label: const Text('حفظ التعديلات'),
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 244, 168, 196),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctl, String label) {
    return TextField(
      controller: ctl,
      style: TextStyle(color: AppColors.textOnNeon),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.glass,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDetailView(Trip event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: GoogleFonts.orbitron(
            color: AppColors.gradientStart,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '📅 ${_formatDate(event.date)}',
          style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
        ),
        Text(
          '📍 ${event.venue}',
          style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
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
                      point: event.venueLocation!,
                      width: 36,
                      height: 36,
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
    );
  }

  Widget _buildSettingsList(BuildContext context, Trip event) {
    final items = [
      {
        'title': 'الميزانية والتكلفة',
        'icon': Icons.attach_money,
        'page': TripBudgetPage(eventId: event.id),
      },

      {
        'title': 'تنظيم المهام',
        'icon': Icons.checklist_rtl,
        'page': TripToDoListPage(eventId: event.id),
      },
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (ctx, i) {
        final it = items[i];
        return Card(
          color: AppColors.glass,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(it['icon'] as IconData, color: AppColors.gradientEnd),
            title: Text(
              it['title'] as String,
              style: GoogleFonts.orbitron(
                color: AppColors.textOnNeon,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white70,
            ),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => it['page'] as Widget),
                ),
          ),
        );
      },
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
