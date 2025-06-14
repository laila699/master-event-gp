import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/screens/chat_list_screen.dart';
import 'package:masterevent/screens/vendor_dashboard/booking_tab.dart';
import 'package:masterevent/screens/vendor_dashboard/manage_provider_screen.dart';
import 'package:masterevent/screens/vendor_dashboard/menu_tab.dart';
import 'package:masterevent/screens/vendor_dashboard/offering_tab.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_provider.dart';
import '../auth/login_screen.dart';

class VendorDashboardScreen extends ConsumerStatefulWidget {
  const VendorDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VendorDashboardScreen> createState() =>
      _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends ConsumerState<VendorDashboardScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Neon accent colors
    final accent1 = Theme.of(context).colorScheme.primary;
    final accent2 = Theme.of(context).colorScheme.secondary;

    // Auth guard
    final authState = ref.watch(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) {
      Future.microtask(
        () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
      );
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final User user = authState.user!;
    if (user.role != 'vendor' || user.vendorProfile == null) {
      return Scaffold(
        backgroundColor: accent1.withOpacity(0.2),
        appBar: AppBar(
          title: Text('غير مصرح', style: GoogleFonts.audiowide(color: accent2)),
          backgroundColor: accent1,
        ),
        body: Center(
          child: Text(
            'هذه الصفحة مخصصة للبائعين فقط',
            style: GoogleFonts.audiowide(color: accent2, fontSize: 16),
          ),
        ),
      );
    }

    // Tabs and views
    final vendorId = user.id;
    final tabs = <Tab>[
      Tab(
        child: Text(
          'العروض',
          style: GoogleFonts.audiowide(color: Colors.white),
        ),
      ),
      Tab(
        child: Text('الحجز', style: GoogleFonts.audiowide(color: Colors.white)),
      ),
      Tab(
        child: Text(
          'قائمة الطعام',
          style: GoogleFonts.audiowide(color: Colors.white),
        ),
      ),
      Tab(
        child: Text(
          'التفاصيل',
          style: GoogleFonts.audiowide(color: Colors.white),
        ),
      ),
      Tab(
        child: Text(
          'المحادثات',
          style: GoogleFonts.audiowide(color: Colors.white),
        ),
      ),
    ];
    final views = <Widget>[
      OfferingTab(vendorId: vendorId),
      BookingTab(),
      MenuTab(vendorId: vendorId),
      Consumer(
        builder: (_, ref, __) {
          final asyncModel = ref.watch(providerModelFamily(vendorId));
          return asyncModel.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, _) => Center(
                  child: Text('خطأ: $e', style: TextStyle(color: accent2)),
                ),
            data: (model) => ManageProviderScreen(provider: model),
          );
        },
      ),
      ChatListScreen(),
    ];

    // Init or update controller
    if (_tabController == null || _tabController!.length != tabs.length) {
      _tabController?.dispose();
      _tabController = TabController(length: tabs.length, vsync: this);
    }

    return Stack(
      children: [
        // Background glow
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.7, -0.7),
              radius: 1.6,
              colors: [accent2, Colors.black],
            ),
          ),
        ),
        // Blur layer
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        // Scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.3),
            elevation: 0,
            title: Text(
              'لوحة البائع: ${user.name}',
              style: GoogleFonts.audiowide(color: accent1),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: accent2),
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: accent1,
              indicatorWeight: 4,
              labelStyle: GoogleFonts.audiowide(fontWeight: FontWeight.w600),
              labelColor: accent1,
              unselectedLabelColor: Colors.white70,
              tabs: tabs,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                  child: TabBarView(
                    controller: _tabController,
                    children: views,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
