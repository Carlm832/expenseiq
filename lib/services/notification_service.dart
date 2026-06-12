import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String channelId = 'expenseiq_alerts';
  static const String channelName = 'ExpenseIQ Alerts';
  static const String channelDescription =
      'Budget alerts, expense updates, and app notifications';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
      ),
    );

    FirebaseMessaging.onMessage.listen(_showRemoteMessage);

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Deep-link handling can be added here later.
  }

  Future<void> _showRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await show(
      id: 'remote_${message.hashCode}',
      title: notification.title ?? 'ExpenseIQ',
      body: notification.body ?? '',
      type: 'info',
    );
  }

  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }

    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    return false;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await initialize();

    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidPlugin?.requestNotificationsPermission() ?? false;
      return granted;
    }

    if (Platform.isIOS) {
      final iosPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;

      if (!granted) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      }
      return granted;
    }

    return false;
  }

  Future<void> show({
    required String id,
    required String title,
    required String body,
    String type = 'info',
  }) async {
    if (kIsWeb) return;
    await initialize();

    final enabled = await areNotificationsEnabled();
    if (!enabled) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(_colorForType(type)),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id.hashCode,
      title,
      body,
      details,
    );
  }

  int _colorForType(String type) {
    switch (type) {
      case 'warning':
        return 0xFFF59E0B;
      case 'success':
        return 0xFF10B981;
      default:
        return 0xFF6366F1;
    }
  }
}
