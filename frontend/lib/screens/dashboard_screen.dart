// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import 'my_events_screen.dart';
// Make sure this import points at your vendor‐dashboard file:
import 'vendor_dashboard/dashboard_screen.dart' show VendorDashboardScreen;

class DashboardScreen extends StatelessWidget {
  final User user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (user.role) {
      case 'organizer':
        return MyEventsScreen(user: user);
      case 'vendor':
        // <— fix: return VendorDashboardScreen, not DashboardScreen again
        return const VendorDashboardScreen();
      case 'admin':
      default:
        return _GenericHomeScreen(user: user);
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
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'مرحبًا بك في تطبيق Master Event!\n\n'
          'لا توجد لوحة مخصصة للصلاحية "${user.role}".',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
