// lib/services/notification_service.dart
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tr_provider.dart'; // where you register / delete tokens

/* ────────────────────────────────────────────────────────────────────────── */
/*  1. Simple in–memory model + Riverpod state for in-app notification list   */
/* ────────────────────────────────────────────────────────────────────────── */

//يمثل اشعار واحد
class NotificationItem {
  NotificationItem({
    required this.title,
    required this.body,
    required this.data,
  }) : receivedAt = DateTime.now();

  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime receivedAt; // حفظ وقت الاستلام
}

// لما يوصل اشعار جديد، يتم اضافته الى قائمة الاشعارات
// باستخدام Riverpod state notifier
class _NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  _NotificationsNotifier() : super([]);
  void add(NotificationItem n) => state = [n, ...state];
}


final notificationsProvider =
    StateNotifierProvider<_NotificationsNotifier, List<NotificationItem>>(
      (_) => _NotificationsNotifier(),
    );

/* ────────────────────────────────────────────────────────────────────────── */
/*  2. Notification service                                                  */
/* ────────────────────────────────────────────────────────────────────────── */
// انشاء المزود  : notificationServiceProvider
final notificationServiceProvider = Provider((ref) {
  final svc = NotificationService._(ref);
  // initialise asynchronously without blocking provider creation
  svc.init();
  return svc;
});

class NotificationService {
  NotificationService._(this._ref);

  final ProviderRef _ref;
  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  /* ---------- Constants -------------------------------------------------- */
  static const _defaultChannelId = 'MESSAGE_CHANNEL'; // fallback

  static const List<AndroidNotificationChannel> _predefinedChannels = [
    AndroidNotificationChannel(
      'MESSAGE_CHANNEL',
      'الرسائل الواردة',
      description: 'إشعارات الرسائل داخل التطبيق',
      importance: Importance.high,
    ),
    AndroidNotificationChannel(
      'BOOKING_CHANNEL',
      'حالة الحجوزات',
      description: 'قبول أو رفض الحجز',
      importance: Importance.high,
    ),
    AndroidNotificationChannel(
      'DEFAULT_CHANNEL',
      'عام',
      description: 'إشعارات عامة',
      importance: Importance.defaultImportance,
    ),
  ];

  /* ---------- Public API ------------------------------------------------- */
  Future<void> init() async {
    await _initLocal(); // تهيئة الإشعارات المحلية
    await _initFCM(); // الحصول على التوكن وتوصيل المستمعين
  }

  /// Call on logout
  Future<void> unregisterToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _ref.read(eventServiceProvider).deletePushToken(token);
    }
  }

  /* ---------- Local notifications --------------------------------------- */
  Future<void> _initLocal() async {
    /* 1. Init plugin */
    const androidInit = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ); // ensure icon
    await _local.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: (_) {}, // deep-links here if wanted
    );

    /* 2. Android 13+ runtime permission */
    // For Android 13+ notification permission, consider using the permission_handler package if needed.
    // Firebase Messaging's requestPermission() handles push notification permissions.

    /* 3. Create predefined channels once */
    if (Platform.isAndroid) {
      final impl =
          _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      for (final ch in _predefinedChannels) {
        await impl?.createNotificationChannel(ch);
      }
    }
  }

  /* ---------- Firebase Cloud Messaging ---------------------------------- */
  Future<void> _initFCM() async {
    final perm = await _messaging.requestPermission();
    if (perm.authorizationStatus != AuthorizationStatus.authorized) return;

    /* ─ Register / refresh token with your backend ─ */
    await _registerToken();
    _messaging.onTokenRefresh.listen(_registerToken);

    /* ─ Foreground ─ */
    // اشعار اثناء فتح التطبيق 
    FirebaseMessaging.onMessage.listen(_handleMessage);  

    /* ─ App opened from tray while backgrounded ─ */ 
    //فتح الاشعارات من الخلفيه 
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    /* ─ Cold-start notification tap ─ */ 
    //فتح الاشعار من حالة اغلاق كامل 
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleMessage(initial);
  }

// send fcm token to backend
  Future<void> _registerToken([String? token]) async {
    token ??= await _messaging.getToken();
    if (token != null) {
      await _ref.read(eventServiceProvider).registerPushToken(token);
    }
  }

  /* ---------- Message handler ------------------------------------------- */
  // receive a message from FCM
  void _handleMessage(RemoteMessage msg) {
    final n = msg.notification;
    if (n == null) return; // data-only, ignore

    final channelId =
        msg.notification?.android?.channelId ??
        _defaultChannelId; // backend decides

    _showLocal(
      id: msg.hashCode,
      title: n.title,
      body: n.body,
      channelId: channelId,
    );

    _ref
        .read(notificationsProvider.notifier)
        .add(
          NotificationItem(
            title: n.title ?? '',
            body: n.body ?? '',
            data: msg.data,
          ),
        );
  }

  /* ---------- Show local notification ----------------------------------- */
  Future<void> _showLocal({
    required int id,
    required String? title,
    required String? body,
    required String channelId,
  }) async {
    /* If the backend suddenly sends a new channel we never created
       before, create it on the fly so Android 8+ will display it. */
    if (Platform.isAndroid) {
      final impl =
          _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final existing = await impl?.getNotificationChannels() ?? [];
      final exists = existing.any((c) => c.id == channelId);
      if (!exists) {
        await impl?.createNotificationChannel(
          AndroidNotificationChannel(
            channelId,
            channelId, // show ID as name until you push an update that localises it
            importance: Importance.high,
          ),
        );
      }
    }

    await _local.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId, // visible name (localise if you know it)
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: null,
    );
  }
}
