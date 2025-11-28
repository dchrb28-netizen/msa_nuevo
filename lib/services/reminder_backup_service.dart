import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:workmanager/workmanager.dart';

/// Sistema de respaldo para recordatorios que funciona incluso si
/// las notificaciones programadas fallan
class ReminderBackupService {
  static const String taskName = 'reminderCheck';
  static const String taskTag = 'reminderCheckTask';

  /// Inicializa WorkManager para verificaciones periódicas
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
    
    developer.log(
      '✅ ReminderBackupService initialized',
      name: 'ReminderBackupService.init',
    );
  }

  /// Registra la tarea periódica de verificación
  static Future<void> registerPeriodicCheck() async {
    try {
      await Workmanager().registerPeriodicTask(
        taskTag,
        taskName,
        frequency: const Duration(minutes: 15), // Mínimo permitido
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      
      developer.log(
        '✅ Periodic reminder check registered (every 15 min)',
        name: 'ReminderBackupService.registerPeriodicCheck',
      );
    } catch (e) {
      developer.log(
        '❌ Failed to register periodic check: $e',
        name: 'ReminderBackupService.registerPeriodicCheck',
      );
    }
  }

  /// Cancela la verificación periódica
  static Future<void> cancelPeriodicCheck() async {
    await Workmanager().cancelByTag(taskTag);
    developer.log(
      '🛑 Periodic reminder check cancelled',
      name: 'ReminderBackupService.cancelPeriodicCheck',
    );
  }

  /// Verifica si hay recordatorios que deberían haber sonado
  static Future<List<Reminder>> checkPendingReminders() async {
    try {
      if (!Hive.isBoxOpen('reminders')) {
        await Hive.openBox<Reminder>('reminders');
      }
      
      final box = Hive.box<Reminder>('reminders');
      final now = TimeOfDay.now();
      final today = DateTime.now().weekday; // 1=Monday, 7=Sunday
      
      final pending = <Reminder>[];
      
      for (var reminder in box.values) {
        if (!reminder.isActive) continue;
        
        // Verificar si hoy es un día programado
        final todayIndex = today == 7 ? 6 : today - 1; // Convertir a 0-6
        if (!reminder.days[todayIndex]) continue;
        
        // Verificar si la hora ya pasó (con margen de 15 min)
        final reminderTime = reminder.hour * 60 + reminder.minute;
        final currentTime = now.hour * 60 + now.minute;
        
        // Si la hora del recordatorio pasó en los últimos 15 minutos
        if (currentTime >= reminderTime && currentTime <= reminderTime + 15) {
          pending.add(reminder);
        }
      }
      
      developer.log(
        'Found ${pending.length} pending reminders',
        name: 'ReminderBackupService.checkPendingReminders',
      );
      
      return pending;
    } catch (e) {
      developer.log(
        'Error checking reminders: $e',
        name: 'ReminderBackupService.checkPendingReminders',
      );
      return [];
    }
  }
}

/// Callback que se ejecuta en background
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      developer.log(
        '🔔 Background task started: $task',
        name: 'ReminderBackupService.callbackDispatcher',
      );

      // Inicializar Hive si no está inicializado
      if (!Hive.isBoxOpen('reminders')) {
        try {
          await Hive.initFlutter();
          // Registrar adaptadores si es necesario
          if (!Hive.isAdapterRegistered(12)) {
            Hive.registerAdapter(ReminderAdapter());
          }
        } catch (e) {
          developer.log(
            'Error initializing Hive in background: $e',
            name: 'ReminderBackupService.callbackDispatcher',
          );
        }
      }

      // Verificar recordatorios pendientes
      final pending = await ReminderBackupService.checkPendingReminders();
      
      if (pending.isNotEmpty) {
        // Enviar notificaciones para recordatorios pendientes
        final notificationService = NotificationService();
        await notificationService.init();
        
        for (var reminder in pending) {
          await notificationService.showNotification(
            reminder.id.hashCode,
            '⏰ ${reminder.title}',
            'Es hora de tu hábito diario',
          );
          
          developer.log(
            '✅ Sent backup notification for: ${reminder.title}',
            name: 'ReminderBackupService.callbackDispatcher',
          );
        }
      }
      
      return Future.value(true);
    } catch (e) {
      developer.log(
        '❌ Background task failed: $e',
        name: 'ReminderBackupService.callbackDispatcher',
      );
      return Future.value(false);
    }
  });
}
