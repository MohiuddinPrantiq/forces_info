import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class Notification_Sch {
  static final _notification = FlutterLocalNotificationsPlugin();

  static init() {
    _notification.initialize(InitializationSettings(
      android : AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
    tz.initializeTimeZones();
  }

  static scheduledNotification(String title, String body,tz.TZDateTime contestStartTime,int id) async {
    var androidDetails = const AndroidNotificationDetails(
      'contest',
      'forces_info',
      channelDescription: 'contest notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iosDetails = const DarwinNotificationDetails();
    var notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _notification.zonedSchedule(
        id,
        title,
        body,
        contestStartTime,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    print('Notification set at ${contestStartTime}');
    print(DateTime.now());
  }
  static Future<void> cancelNotification(int notificationId) async {
    try {
      await _notification.cancel(notificationId);
      print("Notification with ID $notificationId has been canceled.");
    } catch (e) {
      print("Error canceling notification: $e");
    }
  }
}