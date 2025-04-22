import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // initialize the plugin
  Future<void> iniNotification() async {
    if (_isInitialized) return;

    // Android initialization settings
    const initSettingAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const initSettingIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // initialization settings for both platforms
    const initSettings = InitializationSettings(
      android: initSettingAndroid,
      iOS: initSettingIOS,
    );

    // initialize the plugin with the settings
    await notificationPlugin.initialize(initSettings);

    _isInitialized = true; // ✅ ne pas oublier de changer l’état
  }

  // Notification detail setup
  NotificationDetails notificationDetails(String type) {
    switch (type) {
      case 'borrowApproved':
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'borrow_channel',
            'Borrow Notifications',
            channelDescription: 'Notifications about borrow requests',
            importance: Importance.high,
            priority: Priority.high,
            color: Color.fromARGB(255, 66, 196, 27),
          ),
          iOS: DarwinNotificationDetails(),
        );
      case 'borrowRejected':
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'borrow_channel',
            'Borrow Notifications',
            channelDescription: 'Notifications about borrow requests',
            importance: Importance.high,
            priority: Priority.high,
            color: Color.fromARGB(255, 200, 25, 25),
          ),
          iOS: DarwinNotificationDetails(),
        );

      case 'review':
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'review_channel',
            'Review Notifications',
            channelDescription: 'Notifications about reviews',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            color: Color.fromARGB(255, 179, 70, 194),
          ),
          iOS: DarwinNotificationDetails(),
        );

      case 'demand':
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'demand_channel',
            'Demand Notifications',
            channelDescription: 'Notifications about book demands',
            importance: Importance.high,
            priority: Priority.high,
            color: Color.fromARGB(255, 60, 77, 235),
          ),
          iOS: DarwinNotificationDetails(),
        );

      default:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Notifications',
            channelDescription: 'General notifications',
            importance: Importance.low,
            priority: Priority.low,
          ),
          iOS: DarwinNotificationDetails(),
        );
    }
  }

  // Show notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String type = 'default', // 👈 type ajouté
  }) async {
    await notificationPlugin.show(id, title, body, notificationDetails(type));
  }
}
