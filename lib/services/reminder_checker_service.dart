import 'dart:developer' as developer;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import '../models/reminder.dart';
import 'notification_service.dart';

/// Servicio de verificación activa de recordatorios usando WorkManager
/// Este servicio verifica cada 15 minutos si hay recordatorios que deban dispararse
/// Es un respaldo robusto para cuando las notificaciones programadas fallan
class ReminderCheckerService {
  static const String taskName = 'reminderChecker';
  static const String uniqueName = 'reminderCheckerTask';
  
  /// Inicializar el servicio de verificación de recordatorios
  static Future<void> initialize() async {
    developer.log(
      'Initializing ReminderCheckerService',
      name: 'ReminderCheckerService',
    );
    
    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      
      // Registrar tarea periódica cada 15 minutos
      // NOTA: En modo debug, Android permite mínimo 15 minutos para tareas periódicas
      // Para testing más rápido, usamos initialDelay con una tarea one-time
      await Workmanager().registerPeriodicTask(
        uniqueName,
        taskName,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(seconds: 30), // Primera ejecución en 30 segundos
        constraints: Constraints(
          networkType: NetworkType.notRequired,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 1),
      );
      
      developer.log(
        '✅ ReminderCheckerService initialized - first check in 30s, then every 15 minutes',
        name: 'ReminderCheckerService',
      );
    } catch (e) {
      developer.log(
        '⚠️ ReminderCheckerService initialization failed: $e (this is OK, will retry)',
        name: 'ReminderCheckerService',
      );
    }
  }
  
  /// Cancelar el servicio de verificación
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(uniqueName);
    developer.log(
      'ReminderCheckerService cancelled',
      name: 'ReminderCheckerService',
    );
  }
}

/// Callback que se ejecuta en background por WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      developer.log(
        '🔍 ReminderChecker task started: $task',
        name: 'ReminderCheckerService',
      );
      
      // Inicializar Hive (solo si no está ya inicializado)
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
      
      final now = DateTime.now();
      final currentTimeInMinutes = now.hour * 60 + now.minute;
      final currentWeekday = now.weekday; // 1=Lun, 7=Dom
      
      developer.log(
        '⏰ Checking reminders: ${now.hour}:${now.minute} day=$currentWeekday',
        name: 'ReminderCheckerService',
      );
      
      int checkedCount = 0;
      int triggeredCount = 0;
      
      // Verificar cada recordatorio activo
      for (var reminder in remindersBox.values) {
        if (!reminder.isActive) continue;
        
        checkedCount++;
        
        // Verificar si este recordatorio debe dispararse hoy
        final dayIndex = currentWeekday - 1; // 0=Lun, 6=Dom
        if (dayIndex < 0 || dayIndex >= reminder.days.length || !reminder.days[dayIndex]) {
          continue;
        }
        
        // Calcular la hora del recordatorio en minutos
        final reminderTimeInMinutes = reminder.hour * 60 + reminder.minute;
        
        // Verificar si estamos dentro de la ventana de tiempo (±15 minutos)
        // Esto asegura que capturemos el recordatorio aunque el sistema
        // retrase la ejecución de WorkManager
        final timeDifference = (currentTimeInMinutes - reminderTimeInMinutes).abs();
        
        if (timeDifference <= 15) {
          developer.log(
            '🔔 Triggering reminder: ${reminder.title} (${reminder.hour}:${reminder.minute})',
            name: 'ReminderCheckerService',
          );
          
          // Disparar notificación
          final notificationService = NotificationService();
          await notificationService.init();
          
          await notificationService.showNotification(
            reminder.id.hashCode + now.day, // ID único por día
            reminder.title,
            'Es hora de tu hábito diario',
          );
          
          triggeredCount++;
        }
      }
      
      developer.log(
        '✅ ReminderChecker completed: checked=$checkedCount triggered=$triggeredCount',
        name: 'ReminderCheckerService',
      );
      
      return true;
    } catch (e, stackTrace) {
      developer.log(
        '❌ ReminderChecker error: $e\n$stackTrace',
        name: 'ReminderCheckerService',
      );
      return false;
    }
  });
}
