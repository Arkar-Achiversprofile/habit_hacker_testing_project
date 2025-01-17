import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
// import 'package:flutter/material.dart';

class NotificationService {
  // static final NotificationService _instance = NotificationService._internal();

  // factory NotificationService() {
  //   return _instance;
  // }

  // NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {}

  static Future<void> init() async {
    // final currentTimeZone = tz.getLocation("Asia/Rangoon");
    // tz.setLocalLocation(tz.getLocation("Asia/Rangoon"));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Future<void> scheduleDailyNotification(DateTime selectedTime) async {
  //   if (selectedTime.isBefore(DateTime.now())) {
  //     selectedTime = selectedTime.add(const Duration(seconds: 10));
  //   }
  //   final tz.TZDateTime scheduledTime =
  //       tz.TZDateTime.from(selectedTime, tz.local);

  //   try {
  //     await _notificationsPlugin.zonedSchedule(
  //         0,
  //         'scheduled title',
  //         'scheduled body',
  //         tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
  //         const NotificationDetails(
  //             android: AndroidNotificationDetails(
  //                 'your channel id', 'your channel name',
  //                 channelDescription: 'your channel description')),
  //         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //         uiLocalNotificationDateInterpretation:
  //             UILocalNotificationDateInterpretation.absoluteTime);

  //     debugPrint('Notification scheduled successfully');
  //   } catch (e) {
  //     debugPrint('Error scheduling notification: $e');
  //   }
  // }

  // NotificationDetails _notificationDetails() {
  //   return const NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       'your_channel_id',
  //       'your_channel_name',
  //       channelDescription: "your channel description",
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       showWhen: false,
  //     ),
  //     iOS: DarwinNotificationDetails(),
  //   );
  // }

  static Future<void> showNotification(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name',
            importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails());
    await _notificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics);
  }

  static Future<void> scheduleNotification(
      String title, String body, DateTime scheduledDate) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      scheduledDate = scheduledDate.add(const Duration(seconds: 10));
    }

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name',
            importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails());
    await _notificationsPlugin.zonedSchedule(0, title, body,
        tz.TZDateTime.from(scheduledDate, tz.local), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exact,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }
}
