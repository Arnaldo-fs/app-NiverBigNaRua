import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await notifications.initialize(settings);

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> mostrarAgora(String titulo, String corpo) async {
    await notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titulo,
      corpo,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_aniversario',
          'Aniversários',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}