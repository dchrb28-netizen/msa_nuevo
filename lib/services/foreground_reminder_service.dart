import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/reminder.dart';
import 'notification_service.dart';

/// Servicio Foreground que verifica recordatorios cada minuto
/// Garantiza notificaciones exactas a la hora programada
class ForegroundReminderService {
  static const String notificationChannelId = 'foreground_reminder_service';
  static const String notificationChannelName = 'Servicio de Recordatorios';
  static const int notificationId = 1000;
  
  /// Inicializar y comenzar el servicio foreground
  static Future<void> start() async {
    // Inicializar foreground task
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: notificationChannelId,
        channelName: notificationChannelName,
        channelDescription: 'Mantiene activo el servicio de recordatorios',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000), // Verificar cada 5 segundos
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    
    // Iniciar el servicio
    await FlutterForegroundTask.startService(
      notificationTitle: 'Recordatorios activos',
      notificationText: 'Verificando recordatorios programados',
      callback: startCallback,
    );
    
    developer.log(
      '✅ ForegroundReminderService started',
      name: 'ForegroundReminderService',
    );
  }
  
  /// Detener el servicio foreground
  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
    developer.log(
      '⏹️ ForegroundReminderService stopped',
      name: 'ForegroundReminderService',
    );
  }
  
  /// Verificar si el servicio está corriendo
  static Future<bool> isRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }
}

/// Callback que se ejecuta en el servicio foreground
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ReminderTaskHandler());
}

/// Handler que verifica los recordatorios
class ReminderTaskHandler extends TaskHandler {
  int _lastCheckedMinute = -1;
  final Map<String, DateTime> _triggeredToday = {}; // Cambiado a Map para guardar última hora disparada
  
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    developer.log(
      '🚀 ReminderTaskHandler started at $timestamp',
      name: 'ForegroundReminderService',
    );
  }
  
  @override
  void onRepeatEvent(DateTime timestamp) async {
    try {
      final now = DateTime.now();
      final currentMinute = now.hour * 60 + now.minute;
      
      // Solo verificar cuando cambia el minuto
      if (currentMinute == _lastCheckedMinute) {
        return;
      }
      
      _lastCheckedMinute = currentMinute;
      
      // Limpiar recordatorios disparados del día anterior
      if (now.hour == 0 && now.minute == 0) {
        _triggeredToday.clear();
      }
      
      developer.log(
        '⏰ Checking reminders at ${now.hour}:${now.minute}',
        name: 'ForegroundReminderService',
      );
      
      // Inicializar Hive si es necesario
      if (!Hive.isBoxOpen('reminders')) {
        await Hive.initFlutter();
        // Registrar adaptador de Reminder si no está registrado
        if (!Hive.isAdapterRegistered(12)) {
          Hive.registerAdapter(ReminderAdapter());
        }
      }
      
      // Abrir box de recordatorios
      Box<Reminder> remindersBox;
      if (Hive.isBoxOpen('reminders')) {
        remindersBox = Hive.box<Reminder>('reminders');
      } else {
        remindersBox = await Hive.openBox<Reminder>('reminders');
      }
      
      int checkedCount = 0;
      int triggeredCount = 0;
      
      // Verificar cada recordatorio activo
      for (var reminder in remindersBox.values) {
        if (!reminder.isActive) continue;
        
        checkedCount++;
        
        // Verificar si este recordatorio debe dispararse hoy
        final currentWeekday = now.weekday; // 1=Lun, 7=Dom
        final dayIndex = currentWeekday - 1; // 0=Lun, 6=Dom
        
        if (dayIndex < 0 || dayIndex >= reminder.days.length || !reminder.days[dayIndex]) {
          continue;
        }
        
        // Verificar si es la hora exacta O si debe repetirse
        bool shouldTrigger = false;
        final reminderKey = '${reminder.id}_${now.year}_${now.month}_${now.day}';
        
        if (reminder.hour == now.hour && reminder.minute == now.minute) {
          // Es la hora exacta - siempre disparar
          shouldTrigger = true;
        } else if (reminder.repeatMinutes > 0 && _triggeredToday.containsKey(reminderKey)) {
          // Verificar si debe repetirse
          final lastTriggered = _triggeredToday[reminderKey]!;
          final minutesSinceLastTrigger = now.difference(lastTriggered).inMinutes;
          
          if (minutesSinceLastTrigger >= reminder.repeatMinutes) {
            shouldTrigger = true;
          }
        }
        
        if (shouldTrigger) {
          _triggeredToday[reminderKey] = now;
          
          developer.log(
            '🔔 Triggering reminder: ${reminder.title} at ${now.hour}:${now.minute}',
            name: 'ForegroundReminderService',
          );
          
          // Disparar notificación
          final notificationService = NotificationService();
          await notificationService.init();
          
          await notificationService.showNotification(
            reminder.id.hashCode + now.hour * 60 + now.minute,
            reminder.title,
            'Es hora de tu hábito diario',
          );
          
          triggeredCount++;
        }
      }
      
      // Actualizar notificación foreground
      if (checkedCount > 0) {
        FlutterForegroundTask.updateService(
          notificationTitle: 'Recordatorios activos',
          notificationText: '$checkedCount recordatorios programados',
        );
      }
      
      if (triggeredCount > 0) {
        developer.log(
          '✅ Triggered $triggeredCount reminders',
          name: 'ForegroundReminderService',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error in ReminderTaskHandler: $e\n$stackTrace',
        name: 'ForegroundReminderService',
      );
    }
  }
  
  @override
  Future<void> onDestroy(DateTime timestamp, bool? quick) async {
    developer.log(
      '⏹️ ReminderTaskHandler destroyed at $timestamp',
      name: 'ForegroundReminderService',
    );
  }
}
