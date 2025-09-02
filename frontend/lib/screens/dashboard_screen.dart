// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softwareGP/screens/admin_dashboard_screen.dart';
import '../models/user.dart';
import 'my_trips_screen.dart'; //for organizer role
import '../screens/vendor_dashboard/dashboard_screen.dart'
    show VendorDashboardScreen; // just this class
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart'; //for location permission

class DashboardScreen extends ConsumerStatefulWidget {
  //  access to Riverpod ref in state
  final User user;
  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override //تعريف الحالة
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    //تشغل مرة واحدة فقط عند انشاء الستيت
    super.initState(); // تستدعي تنفيذ الكود الاساسي في كلاس الاب
    ref.read(notificationServiceProvider); // Register FCM token on app start
    _requestLocationPermission(); // طلب إذن الموقع
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      // إذا تم منح الإذن
      print("📍 Location permission granted.");
    } else if (status.isDenied) {
      print("❗ Location permission denied.");
    } else if (status.isPermanentlyDenied) {
      print(
        // إذا تم رفض الإذن بشكل دائم
        "❌ Location permission permanently denied. Please enable it in settings.",
      );
      openAppSettings();
    }
  }

  @override
  void dispose() {
    // Unregister FCM token on logout/out of dashboard
    ref.read(notificationServiceProvider).unregisterToken();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //build method تحدد اي شاشة
    switch (widget.user.role) {
      case 'organizer':
        return MyTripsScreen(user: widget.user);
      case 'vendor':
        return const VendorDashboardScreen();
      case 'admin':
        return const AdminDashboardScreen();
      default:
        return _GenericHomeScreen(user: widget.user);
    }
  }
}

class _GenericHomeScreen extends StatelessWidget {
  final User user;
  const _GenericHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحبًا، ${user.name}'),
        backgroundColor: const Color.fromARGB(255, 244, 168, 196),
      ),
      body: Center(
        child: Text(
          'مرحبًا بك، ${user.name}! لا توجد لوحة مخصصة لرول ${user.role}.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
