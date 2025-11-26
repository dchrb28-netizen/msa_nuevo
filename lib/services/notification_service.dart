import 'dart:developer' as developer;
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
    // Create Android notification channels explicitly so sound/vibration
    // settings are applied even on API levels that cache channel settings.
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    const AndroidNotificationChannel weeklyChannel = AndroidNotificationChannel(
      'weekly_notification_channel',
      'Weekly Notifications',
      description: 'Weekly reminder notifications',
      importance: Importance.max,
      playSound: true,
    );

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

    await androidPlugin?.createNotificationChannel(weeklyChannel);
    await androidPlugin?.createNotificationChannel(scheduledChannel);
    await androidPlugin?.createNotificationChannel(fastingChannel);
    developer.log(
      'Notification channels created (weekly/scheduled/fasting)',
      name: 'NotificationService.init',
    );
  }

  Future<void> _requestPermissions() async {
    // Solicitar permiso de notificaciones (Android 13+)
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      final result = await Permission.notification.request();
      developer.log(
        'Notification permission result: $result',
        name: 'NotificationService._requestPermissions',
      );
    }
    
    // Solicitar permiso de alarmas exactas (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  /// Verifica y solicita todos los permisos necesarios para notificaciones
  /// Retorna true si todos los permisos fueron concedidos
  Future<bool> checkAndRequestPermissions() async {
    developer.log(
      'Checking notification permissions...',
      name: 'NotificationService.checkAndRequestPermissions',
    );

    // Verificar y solicitar permiso de notificaciones
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

    // Verificar y solicitar permiso de alarmas exactas (Android 12+)
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

  /// Diagnóstico completo del sistema de notificaciones
  /// Retorna un mapa con información detallada sobre el estado
  Future<Map<String, dynamic>> diagnosticNotificationSystem() async {
    final result = <String, dynamic>{};
    
    try {
      // 1. Permisos
      final notificationPerm = await Permission.notification.status;
      final alarmPerm = await Permission.scheduleExactAlarm.status;
      result['permissions'] = {
        'notification': notificationPerm.toString(),
        'exactAlarm': alarmPerm.toString(),
        'allGranted': notificationPerm.isGranted && !alarmPerm.isDenied,
      };
      
      // 2. Notificaciones pendientes
      final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      result['pendingCount'] = pending.length;
      result['pendingNotifications'] = pending.map((n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
      }).toList();
      
      // 3. Canales activos (Android)
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
    developer.log(
      '📅 scheduleWeeklyNotification called: baseId=$baseId time=${time.hour}:${time.minute} days=$days',
      name: 'NotificationService.scheduleWeeklyNotification',
    );
    
    // SOLUCIÓN: Cancelar notificaciones anteriores primero para evitar conflictos
    await cancelWeeklyNotifications(baseId, days);
    await Future.delayed(const Duration(milliseconds: 500)); // Dar tiempo a cancelar
    
    final now = DateTime.now();
    
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        final dayIndex = i + 1; // 1=Lun, 7=Dom
        final notificationId = baseId + dayIndex;
        
        // Calcular la próxima fecha para este día (IGUAL QUE EL AYUNO)
        DateTime scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        
        // Avanzar hasta el día correcto
        while (scheduledDate.weekday != dayIndex) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        
        // Si la hora ya pasó, programar para la próxima semana
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }

        developer.log(
          '  ✓ Day ${i+1} (${_getDayName(dayIndex)}): scheduling for $scheduledDate (id=$notificationId)',
          name: 'NotificationService.scheduleWeeklyNotification',
        );

        // SOLUCIÓN: Intentar con manejo de errores y fallback
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
                // NUEVO: Configuraciones adicionales para Android
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
    
    // SOLUCIÓN: Verificar y mostrar las notificaciones pendientes
    try {
      final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      final reminderNotifications = pendingNotifications
          .where((n) => n.id >= baseId && n.id <= baseId + 7)
          .toList();
      
      developer.log(
        '🎯 Total notifications scheduled: ${days.where((d) => d).length}',
        name: 'NotificationService.scheduleWeeklyNotification',
      );
      developer.log(
        '📌 Total pending (verified): ${reminderNotifications.length}',
        name: 'NotificationService.scheduleWeeklyNotification',
      );
      
      for (var notification in reminderNotifications) {
        developer.log(
          '  ✓ Pending: id=${notification.id} title="${notification.title}"',
          name: 'NotificationService.scheduleWeeklyNotification',
        );
      }
      
      if (reminderNotifications.isEmpty && days.any((d) => d)) {
        developer.log(
          '⚠️ WARNING: No pending notifications found! This may indicate a scheduling problem.',
          name: 'NotificationService.scheduleWeeklyNotification',
        );
      }
    } catch (e) {
      developer.log(
        '⚠️ Could not verify pending notifications: $e',
        name: 'NotificationService.scheduleWeeklyNotification',
      );
    }
  }

  String _getDayName(int dayIndex) {
    const days = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[dayIndex];
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int day, TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
    
    developer.log(
      'Finding next instance: target_day=$day current_weekday=${scheduledDate.weekday} initial_date=$scheduledDate',
      name: 'NotificationService._nextInstanceOfDayAndTime',
    );
    
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    developer.log(
      'Found next instance: $scheduledDate (${scheduledDate.weekday}) - now=$now',
      name: 'NotificationService._nextInstanceOfDayAndTime',
    );
    
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    developer.log(
      'Calculating next time: requested=${time.hour}:${time.minute} now=$now scheduled=$scheduledDate',
      name: 'NotificationService._nextInstanceOfTime',
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      developer.log(
        'Time already passed today, moved to tomorrow: $scheduledDate',
        name: 'NotificationService._nextInstanceOfTime',
      );
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

  /// Método de prueba: muestra una notificación inmediata y programa otra
  Future<void> scheduleTestNotification({int secondsFromNow = 60}) async {
    developer.log(
      '🧪 TEST: Showing immediate notification',
      name: 'NotificationService.scheduleTestNotification',
    );

    // Primero muestra una notificación INMEDIATA para verificar que funciona
    await flutterLocalNotificationsPlugin.show(
      999999, // ID único para prueba
      '🧪 Notificación de Prueba INMEDIATA',
      'Si ves esto, las notificaciones básicas funcionan! Ahora esperando notificación programada...',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_notification_channel',
          'Weekly Notifications',
          channelDescription: 'Weekly reminder notifications',
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

    // Luego programa una para dentro de X segundos
    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsFromNow));
    
    developer.log(
      '🧪 TEST: Scheduling notification in $secondsFromNow seconds at $scheduledDate',
      name: 'NotificationService.scheduleTestNotification',
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999998, // ID diferente
      '🧪 Notificación PROGRAMADA',
      'Han pasado $secondsFromNow segundos! Las notificaciones programadas funcionan!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_notification_channel',
          'Weekly Notifications',
          channelDescription: 'Weekly reminder notifications',
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
