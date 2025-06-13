// lib/services/notification_service.dart

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';

// 1️⃣ Define a simple model for in-app state (if you choose to track them):
class NotificationItem {
  final String title;
  final String body;
  final DateTime receivedAt;
  final Map<String, dynamic>? data;
  NotificationItem({required this.title, required this.body, this.data})
    : receivedAt = DateTime.now();
}

// 2️⃣ Expose a StateNotifier to hold the list of notifications
class _NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  _NotificationsNotifier() : super([]);
  void add(NotificationItem item) => state = [item, ...state];
}

final notificationsProvider =
    StateNotifierProvider<_NotificationsNotifier, List<NotificationItem>>(
      (_) => _NotificationsNotifier(),
    );

// 3️⃣ Your service:
final notificationServiceProvider = Provider((ref) => NotificationService(ref));

class NotificationService {
  final ProviderRef ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  NotificationService(this.ref) {
    _initLocal();
    _initFCM();
  }

  /// 1) Configure local notification channels & icon
  void _initLocal() async {
    const androidInit = AndroidInitializationSettings('@drawable/message_icon');

    await _local.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // optional: navigate to details
        return;
      },
    );

    if (Platform.isAndroid) {
      // Create the same channel IDs you use in your backend payload:
      const messageChannel = AndroidNotificationChannel(
        'MESSAGE_CHANNEL',
        'الرسائل الواردة',
        description: 'إشعارات الرسائل',
        importance: Importance.high,
      );
      const bookingChannel = AndroidNotificationChannel(
        'BOOKING_CHANNEL',
        'حالة الحجوزات',
        description: 'إشعارات قبول/رفض الحجوزات',
        importance: Importance.high,
      );

      final androidImpl =
          _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImpl?.createNotificationChannel(messageChannel);
      await androidImpl?.createNotificationChannel(bookingChannel);
    }
  }

  /// 2) Hook into FCM, show local & update Riverpod state
  void _initFCM() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    // Register this device token with your backend
    final token = await _messaging.getToken();
    if (token != null) {
      await ref.read(eventServiceProvider).registerPushToken(token);
    }

    // Foreground
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        final channelId =
            msg.notification?.android?.channelId ?? 'MESSAGE_CHANNEL';
        _showLocal(n.hashCode, n.title, n.body, channelId);
        ref
            .read(notificationsProvider.notifier)
            .add(
              NotificationItem(title: n.title!, body: n.body!, data: msg.data),
            );
      }
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        final channelId =
            msg.notification?.android?.channelId ?? 'MESSAGE_CHANNEL';
        _showLocal(n.hashCode, n.title, n.body, channelId);
        ref
            .read(notificationsProvider.notifier)
            .add(
              NotificationItem(title: n.title!, body: n.body!, data: msg.data),
            );
      }
    });

    // Cold start
    final initial = await _messaging.getInitialMessage();
    if (initial?.notification != null) {
      final n = initial!.notification!;
      final channelId =
          initial.notification?.android?.channelId ?? 'MESSAGE_CHANNEL';
      _showLocal(n.hashCode, n.title, n.body, channelId);
      ref
          .read(notificationsProvider.notifier)
          .add(
            NotificationItem(
              title: n.title!,
              body: n.body!,
              data: initial.data,
            ),
          );
    }
  }

  /// Helper to show a local notification on Android
  Future<void> _showLocal(
    int id,
    String? title,
    String? body,
    String channelId,
  ) => _local.show(
    id,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId, // matches the channel you created
        channelId == 'BOOKING_CHANNEL' ? 'حالة الحجوزات' : 'General',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );

  /// Clean‐up on logout
  Future<void> unregisterToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await ref.read(eventServiceProvider).deletePushToken(token);
    }
  }
}
