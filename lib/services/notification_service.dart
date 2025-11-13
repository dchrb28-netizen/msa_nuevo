import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    tz.initializeTimeZones();
    final String timeZoneName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> showNotification(
    int id,
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'fasting_channel',
      'Fasting Notifications',
      channelDescription: 'Notifications for fasting milestones',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_notification_channel',
          'Scheduled Notifications',
          channelDescription: 'Scheduled reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
         iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleWeeklyNotification(
    int baseId,
    String title,
    String body,
    TimeOfDay time,
    List<bool> days,
  ) async {
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        final dayIndex = i + 1; // flutter_local_notifications uses 1 for Monday, 7 for Sunday
        final notificationId = baseId + dayIndex;

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          _nextInstanceOfDayAndTime(dayIndex, time),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'weekly_notification_channel',
              'Weekly Notifications',
              channelDescription: 'Weekly reminder notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int day, TimeOfDay time) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelWeeklyNotifications(int baseId, List<bool> days) async {
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        final dayIndex = i + 1;
        final notificationId = baseId + dayIndex;
        await flutterLocalNotificationsPlugin.cancel(notificationId);
      }
    }
  }
}
