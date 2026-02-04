import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:myapp/models/daily_task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskNotificationService {
  static final TaskNotificationService _instance = TaskNotificationService._internal();
  factory TaskNotificationService() => _instance;
  TaskNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static Function(String?)? onNotificationTap;

  Future<void> init({Function(String?)? onSelectNotification}) async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        onSelectNotification?.call(response.payload);
      },
    );
    onNotificationTap = onSelectNotification;
  }

  Future<void> showPendingTasksNotification(int pendingCount) async {
    if (pendingCount <= 0) return;
    const androidDetails = AndroidNotificationDetails(
      'pending_tasks_channel',
      'Tareas pendientes',
      channelDescription: 'Recordatorios de tareas diarias pendientes',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      1000,
      'Tienes tareas pendientes',
      'Quedan $pendingCount tareas por completar hoy',
      details,
    );
  }

  /// Obtiene el contador de tareas pendientes solo del día actual
  /// Filtra tareas únicas que no sean de hoy y tareas repetidas fuera de su rango
  Future<int> getPendingTasksCountForToday() async {
    try {
      if (!Hive.isBoxOpen('daily_tasks')) {
        await Hive.openBox('daily_tasks');
      }
      
      final box = Hive.box('daily_tasks');
      final today = DateTime.now();
      int pendingCount = 0;

      for (int i = 0; i < box.length; i++) {
        try {
          final item = box.getAt(i);
          if (item is Map) {
            final task = DailyTask.fromMap(item);
            // Verificar si la tarea debe mostrarse hoy
            if (!task.shouldShowOnDay(today)) {
              continue;
            }
            
            // Para tareas repetidas, usar isCompletedOnDay
            if (task.repeatType == TaskRepeatType.weekly) {
              if (!task.isCompletedOnDay(today)) {
                pendingCount++;
              }
            } else if (!task.completed) {
              // Para tareas únicas, usar el campo completed
              pendingCount++;
            }
          }
        } catch (_) {}
      }

      return pendingCount;
    } catch (_) {
      return 0;
    }
  }
}
