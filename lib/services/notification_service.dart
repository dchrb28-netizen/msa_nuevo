// Implementación removida: el proyecto ahora usa `TaskNotificationService`.
// Este archivo se mantiene vacío intencionalmente para evitar conflictos.

// Si desea restaurar una implementación global de notificaciones,
// cree una clase dedicada y asegúrese de no duplicar definiciones.

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
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
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    tz.initializeTimeZones();
    final String timeZoneName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _requestPermissions();

    if (kIsWeb) return; // Channels are not applicable on web

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    const AndroidNotificationChannel scheduledChannel =
        AndroidNotificationChannel(
          'scheduled_notification_channel',
          'Scheduled Notifications',
          description: 'Scheduled reminder notifications',
          importance: Importance.max,
          playSound: true,
        );

    const AndroidNotificationChannel fastingChannel =
        AndroidNotificationChannel(
          'fasting_channel',
          'Fasting Notifications',
          description: 'Notifications for fasting milestones',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );

    await androidPlugin?.createNotificationChannel(scheduledChannel);
    await androidPlugin?.createNotificationChannel(fastingChannel);
    developer.log(
      'Notification channels created (scheduled/fasting)',
      name: 'NotificationService.init',
    );
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return; // Permissions are not handled this way on web

    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      final result = await Permission.notification.request();
      developer.log(
        'Notification permission result: $result',
        name: 'NotificationService._requestPermissions',
      );
    }
    
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<bool> checkAndRequestPermissions() async {
    if (kIsWeb) {
      developer.log(
        'Skipping permission check on web',
        name: 'NotificationService.checkAndRequestPermissions',
      );
      return true; // Assume granted on web as it's handled by browser
    }

    developer.log(
      'Checking notification permissions...',
      name: 'NotificationService.checkAndRequestPermissions',
    );

    PermissionStatus notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      notificationStatus = await Permission.notification.request();
      developer.log(
        'Notification permission requested: $notificationStatus',
        name: 'NotificationService.checkAndRequestPermissions',
      );
    }

    if (!notificationStatus.isGranted) {
      developer.log(
        'Notification permission DENIED',
        name: 'NotificationService.checkAndRequestPermissions',
      );
      return false;
    }

    PermissionStatus alarmStatus = await Permission.scheduleExactAlarm.status;
    if (alarmStatus.isDenied) {
      alarmStatus = await Permission.scheduleExactAlarm.request();
      developer.log(
        'Exact alarm permission requested: $alarmStatus',
        name: 'NotificationService.checkAndRequestPermissions',
      );
    }

    final allGranted = notificationStatus.isGranted && !alarmStatus.isDenied;
    developer.log(
      'All permissions granted: $allGranted',
      name: 'NotificationService.checkAndRequestPermissions',
    );

    return allGranted;
  }

  Future<Map<String, dynamic>> diagnosticNotificationSystem() async {
    final result = <String, dynamic>{};
    
    try {
      if (!kIsWeb) {
        final notificationPerm = await Permission.notification.status;
        final alarmPerm = await Permission.scheduleExactAlarm.status;
        result['permissions'] = {
          'notification': notificationPerm.toString(),
          'exactAlarm': alarmPerm.toString(),
          'allGranted': notificationPerm.isGranted && !alarmPerm.isDenied,
        };
      } else {
        result['permissions'] = 'Not applicable on web';
      }
      
      final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      result['pendingCount'] = pending.length;
      result['pendingNotifications'] = pending.map((n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
      }).toList();
      
      if (!kIsWeb) {
        final androidPlugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidPlugin != null) {
          final channels = await androidPlugin.getNotificationChannels();
          result['channels'] = channels?.map((c) => {
            'id': c.id,
            'name': c.name,
            'importance': c.importance.toString(),
          }).toList() ?? [];
        }
      }
      
      developer.log(
        '🔍 Diagnostic results: $result',
        name: 'NotificationService.diagnosticNotificationSystem',
      );
      
    } catch (e, stackTrace) {
      developer.log(
        '❌ Diagnostic error: $e\n$stackTrace',
        name: 'NotificationService.diagnosticNotificationSystem',
      );
      result['error'] = e.toString();
    }
    
    return result;
  }

  Future<void> showNotification(int id, String title, String body) async {
    developer.log(
      'showNotification called id=$id title=$title',
      name: 'NotificationService.showNotification',
    );
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'fasting_channel',
          'Fasting Notifications',
          channelDescription: 'Notifications for fasting milestones',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          showWhen: false,
          playSound: true,
          enableVibration: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    if (kIsWeb) return; // zonedSchedule is not supported on web
    developer.log(
      'scheduleNotification called id=$id scheduledTime=$scheduledTime',
      name: 'NotificationService.scheduleNotification',
    );
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
          icon: '@drawable/ic_notification',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
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
    if (kIsWeb) return; // zonedSchedule is not supported on web
    developer.log(
      '📅 scheduleWeeklyNotification called: baseId=$baseId time=${time.hour}:${time.minute} days=$days',
      name: 'NotificationService.scheduleWeeklyNotification',
    );
    
    await cancelWeeklyNotifications(baseId, days);
    await Future.delayed(const Duration(milliseconds: 500));
    
    final now = DateTime.now();
    
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        final dayIndex = i + 1;
        final notificationId = baseId + dayIndex;
        
        DateTime scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        
        while (scheduledDate.weekday != dayIndex) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }

        developer.log(
          '  ✓ Day ${i+1} (${_getDayName(dayIndex)}): scheduling for $scheduledDate (id=$notificationId)',
          name: 'NotificationService.scheduleWeeklyNotification',
        );

        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId,
            title,
            body,
            tz.TZDateTime.from(scheduledDate, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'scheduled_notification_channel',
                'Scheduled Notifications',
                channelDescription: 'Scheduled reminder notifications',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@drawable/ic_notification',
                playSound: true,
                enableVibration: true,
                enableLights: true,
                ledColor: Color(0xFF4CAF50),
                ledOnMs: 1000,
                ledOffMs: 500,
                autoCancel: false,
                ongoing: false,
                showWhen: true,
              ),
              iOS: DarwinNotificationDetails(
                presentSound: true,
                presentAlert: true,
                presentBadge: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
          
          developer.log(
            '  ✅ Scheduled successfully: id=$notificationId',
            name: 'NotificationService.scheduleWeeklyNotification',
          );
        } catch (e, stackTrace) {
          developer.log(
            '  ❌ Error scheduling notification: $e\n$stackTrace',
            name: 'NotificationService.scheduleWeeklyNotification',
          );
        }
      }
    }
  }

  String _getDayName(int dayIndex) {
    const days = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[dayIndex];
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelWeeklyNotifications(int baseId, List<bool> days) async {
    if (kIsWeb) return;
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        final dayIndex = i + 1;
        final notificationId = baseId + dayIndex;
        await flutterLocalNotificationsPlugin.cancel(notificationId);
      }
    }
  }

  Future<void> scheduleTestNotification({int secondsFromNow = 60}) async {
     if (kIsWeb) return;
    developer.log(
      '🧪 TEST: Showing immediate notification',
      name: 'NotificationService.scheduleTestNotification',
    );

    await flutterLocalNotificationsPlugin.show(
      999999,
      '🧪 Notificación de Prueba INMEDIATA',
      'Si ves esto, las notificaciones básicas funcionan! Ahora esperando notificación programada...',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_notification_channel',
          'Scheduled Notifications',
          channelDescription: 'Scheduled reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
      ),
    );

    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsFromNow));
    
    developer.log(
      '🧪 TEST: Scheduling notification in $secondsFromNow seconds at $scheduledDate',
      name: 'NotificationService.scheduleTestNotification',
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999998,
      '🧪 Notificación PROGRAMADA',
      'Han pasado $secondsFromNow segundos! Las notificaciones programadas funcionan!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_notification_channel',
          'Scheduled Notifications',
          channelDescription: 'Scheduled reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    
    developer.log(
      '✅ TEST: Immediate shown + notification scheduled for $scheduledDate',
      name: 'NotificationService.scheduleTestNotification',
    );
  }
}
