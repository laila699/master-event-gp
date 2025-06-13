// lib/screens/vendor_dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/screens/chat_list_screen.dart';
import 'package:masterevent/screens/vendor_dashboard/booking_tab.dart';
import 'package:masterevent/screens/vendor_dashboard/manage_provider_screen.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_provider.dart'; // for providerModelFamily
import '../auth/login_screen.dart';
import 'offering_tab.dart';
import 'menu_tab.dart';

class VendorDashboardScreen extends ConsumerStatefulWidget {
  const VendorDashboardScreen({super.key});

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
    final authState = ref.watch(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) {
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final User user = authState.user!;
    if (user.role != 'vendor' || user.vendorProfile == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('غير مصرح', style: GoogleFonts.cairo()),
          backgroundColor: Colors.purple,
        ),
        body: Center(
          child: Text(
            'هذه الصفحة مخصصة للبائعين فقط',
            style: GoogleFonts.cairo(fontSize: 16),
          ),
        ),
      );
    }
    final String vendorId = user.id;

    // Build our tabs list based on serviceType
    final serviceType = user.vendorProfile!.serviceType;
    final tabs = <Tab>[
      const Tab(child: Text('العروض', style: TextStyle(color: Colors.white))),
      const Tab(child: Text('الحجز', style: TextStyle(color: Colors.white))),
      const Tab(
        child: Text('قائمة الطعام', style: TextStyle(color: Colors.white)),
      ),
      const Tab(child: Text('التفاصيل', style: TextStyle(color: Colors.white))),
      const Tab(
        child: Text(' المحادثات', style: TextStyle(color: Colors.white)),
      ),
    ];

    final tabViews = <Widget>[
      OfferingTab(vendorId: vendorId),
      BookingTab(),

      MenuTab(vendorId: vendorId),
      Consumer(
        builder: (ctx, ref, _) {
          final asyncModel = ref.watch(providerModelFamily(user.id));
          return asyncModel.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, _) => Center(
                  child: Text(
                    'خطأ: $err',
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                ),
            data: (model) => ManageProviderScreen(provider: model),
          );
        },
      ),
      ChatListScreen(),
    ];

    // Only recreate controller if the length changes
    if (_tabController == null || _tabController!.length != tabs.length) {
      _tabController?.dispose();
      _tabController = TabController(length: tabs.length, vsync: this);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 4,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            'لوحة البائع: ${user.name}',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج',
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
            indicator: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.cairo(),
            tabs: tabs,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TabBarView(controller: _tabController, children: tabViews),
        ),
      ),
    );
  }
}
