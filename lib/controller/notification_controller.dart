import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationController {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationController() {
    _initLocalNotifications();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
        'timer_channel', 'Timer Notifications',
        importance: Importance.max, priority: Priority.high);
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}
