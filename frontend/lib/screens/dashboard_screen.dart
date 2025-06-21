// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/screens/admin_dashboard_screen.dart';
import '../models/user.dart';
import '../screens/my_events_screen.dart';
import '../screens/vendor_dashboard/dashboard_screen.dart'
    show VendorDashboardScreen;
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final User user;
  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(notificationServiceProvider);
    _requestLocationPermission(); // 👈 Add this
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      print("📍 Location permission granted.");
    } else if (status.isDenied) {
      print("❗ Location permission denied.");
    } else if (status.isPermanentlyDenied) {
      print(
        "❌ Location permission permanently denied. Please enable it in settings.",
      );
      openAppSettings();
    }
  }

  @override
  void dispose() {
    // Unregister FCM token on logout/dispose
    ref.read(notificationServiceProvider).unregisterToken();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.user.role) {
      case 'organizer':
        return MyEventsScreen(user: widget.user);
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
        backgroundColor: Colors.purple,
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
