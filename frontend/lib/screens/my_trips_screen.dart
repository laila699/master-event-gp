// lib/screens/my_events_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart'; // For map display
import 'package:latlong2/latlong.dart'; // For map coordinates
import 'package:google_fonts/google_fonts.dart';
import 'package:softwareGP/InvitationScreen.dart';
import 'package:softwareGP/add_trip_screen.dart';
import 'package:softwareGP/models/service_type.dart';
import 'package:softwareGP/screens/all_offering_screen.dart';
import 'package:softwareGP/screens/chat_list_screen.dart';
import 'package:softwareGP/screens/chat_bot_list_screen.dart';
import 'package:softwareGP/screens/notifications_screen.dart';
import 'package:softwareGP/screens/vendor_list_screen.dart';
import 'package:softwareGP/services/notification_service.dart';
import 'package:softwareGP/theme/colors.dart';
import 'package:softwareGP/user_profile.dart';

import '../models/user.dart'; // User model
import '../models/trip.dart'; //event form model to manage event data
import '../providers/tr_provider.dart'; //provider for fetching events to manage event state
import 'trip_details_screen.dart';

/// Home screen with two tabs: "رحلاتي" and "استكشف الخدمات"
class MyTripsScreen extends ConsumerStatefulWidget {
  final User user; //المستخدم الحالي وتعرض بياناته
  const MyTripsScreen({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(notificationServiceProvider); // Register FCM token on app start
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(
      eventListProvider,
    ); // Fetch events from provider
    final primary = Theme.of(context).colorScheme.primary;
    final accent1 = AppColors.gradientStart;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Neon radial background
          DecoratedBox(
            decoration: BoxDecoration(
              //تعريف شكل الحلفية
              gradient: RadialGradient(
                //تدرج لوني  دائري
                center: const Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [accent1, AppColors.background],
              ),
            ),
          ),
          // Glass blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),
          // Main content
          DefaultTabController(
            //تحديد عدد التبويبات
            length: 3,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: AppColors.overlay,
                elevation: 0,
                title: Text(
                  'مرحبًا، ${widget.user.name}',
                  style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    color: AppColors.textOnNeon,
                    onPressed:
                        () => Navigator.push(
                          //انتقال لشاشة الاشعارات
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationsScreen(),
                          ),
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat),
                    color: AppColors.textOnNeon,
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatListScreen(),
                          ),
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person),
                    color: AppColors.textOnNeon,
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.smart_toy),
                    color: AppColors.textOnNeon,
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatBotListScreen(),
                          ),
                        ),
                  ),
                ],
                bottom: TabBar(
                  //تاب اسفل شريط appBar
                  indicator: UnderlineTabIndicator(
                    //شكل الخط
                    borderSide: BorderSide(width: 3.0, color: accent1),
                    insets: const EdgeInsets.symmetric(horizontal: 24.0),
                  ),
                  tabs: [
                    Tab(
                      child: Text(
                        'رحلاتي',
                        style: GoogleFonts.orbitron(
                          color: AppColors.textOnNeon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'استكشف الخدمات',
                        style: GoogleFonts.orbitron(
                          color: AppColors.textOnNeon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'العروض',
                        style: GoogleFonts.orbitron(
                          color: AppColors.textOnNeon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ), // ← new tab
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  // Tab 1: My Trips
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: eventsAsync.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (e, _) => Center(
                            child: Text(
                              'خطأ: $e',
                              style: GoogleFonts.orbitron(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      data: (events) {
                        if (events.isEmpty) {
                          return Center(
                            child: Text(
                              'لا توجد رحلات',
                              style: GoogleFonts.orbitron(
                                color: AppColors.textOnNeon,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          //تعرض الرحلات بقائمة
                          itemCount: events.length, //القائمة حسب عدد العناصر
                          itemBuilder: (ctx, i) {
                            final ev = events[i]; // each ev present trip
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap:
                                    () => Navigator.push(
                                      // بس يضغط على البطاقة ينتقل لصفحة
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => TripDetailsScreen(
                                              eventId: ev.id,
                                            ),
                                      ),
                                    ),
                                child: Card(
                                  color: AppColors.glass,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (ev.venueLocation !=
                                          null) //لو  موقع معين
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                          child: SizedBox(
                                            // تعرض الخريطة
                                            height: 120,
                                            child: FlutterMap(
                                              // مكتبة لرسم الخريطة
                                              options: MapOptions(
                                                initialCenter:
                                                    ev.venueLocation!,
                                                initialZoom: 15,
                                                interactionOptions:
                                                    const InteractionOptions(
                                                      flags:
                                                          InteractiveFlag
                                                              .none, // Disable user interaction
                                                    ),
                                              ),
                                              children: [
                                                TileLayer(
                                                  urlTemplate:
                                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                  subdomains: const [
                                                    'a',
                                                    'b',
                                                    'c',
                                                  ],
                                                ),
                                                MarkerLayer(
                                                  //تحديد موقع الرحلة على الخريطة
                                                  markers: [
                                                    Marker(
                                                      width: 36,
                                                      height: 36,
                                                      point: ev.venueLocation!,
                                                      child: Icon(
                                                        Icons.location_pin,
                                                        color: primary,
                                                        size: 36,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ev.title,
                                              style: GoogleFonts.orbitron(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textOnNeon,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 16,
                                                  color: AppColors.textOnNeon,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(
                                                    ev.date,
                                                  ), // تنسيق تاريخ الرحلة
                                                  style: GoogleFonts.orbitron(
                                                    color: AppColors.textOnNeon,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color: AppColors.textOnNeon,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    ev.venue,
                                                    style: GoogleFonts.orbitron(
                                                      color:
                                                          AppColors.textOnNeon,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Tab 2: Services
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      //عرض الخدمات في شبكة
                      crossAxisCount: 2, //2 columns
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _serviceCard(context, Icons.celebration, 'الاقامة', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => VendorListScreen(
                                    initialType:
                                        VendorServiceType.accommodation,
                                  ),
                            ),
                          );
                        }),
                        _serviceCard(context, Icons.email, 'الدعوات', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvitationScreen(),
                            ),
                          );
                        }),
                        _serviceCard(
                          context,
                          Icons.card_giftcard,
                          'متجر معدات الرحل',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => VendorListScreen(
                                      initialType: VendorServiceType.tools,
                                    ),
                              ),
                            );
                          },
                        ),
                        _serviceCard(context, Icons.chair, 'نقل ومواصلات', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => VendorListScreen(
                                    initialType:
                                        VendorServiceType.transportation,
                                  ),
                            ),
                          );
                        }),
                        _serviceCard(context, Icons.camera_alt, 'التصوير', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => VendorListScreen(
                                    initialType: VendorServiceType.photographer,
                                  ),
                            ),
                          );
                        }),
                        _serviceCard(context, Icons.restaurant, 'المطاعم', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => VendorListScreen(
                                    initialType: VendorServiceType.restaurant,
                                  ),
                            ),
                          );
                        }),
                        _serviceCard(
                          context,
                          Icons.music_note,
                          'المرشدين ',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => VendorListScreen(
                                      initialType: VendorServiceType.guides,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    //all offers
                    padding: const EdgeInsets.all(16.0),
                    child: const AllOffersScreen(),
                  ), // ← new screen
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTripScreen()),
                  );

                  // Check if the event was successfully created
                  if (result == true) {
                    ref.invalidate(eventListProvider);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(
                  'إضافة رحلة',
                  style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
                ),
                backgroundColor: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, //دالة تفعل عند الضغط على البطاقة
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      //  color: const Color.fromARGB(235, 220, 202, 202),
      color: primary,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ), // ← هنا لون النص بني
                fontSize: 16,
                fontWeight: FontWeight.w500,
                //color: AppColors.textOnNeon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    // static function to format date , لتحويل التاريخ الى نص بالعربي
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
