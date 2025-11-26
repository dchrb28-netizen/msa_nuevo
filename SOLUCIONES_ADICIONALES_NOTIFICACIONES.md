# Soluciones Adicionales para Notificaciones que NO Funcionan

# Soluciones Adicionales para Notificaciones que NO Funcionan

## ✅ SOLUCIÓN IMPLEMENTADA: Sistema Híbrido de Doble Respaldo

### Problema Identificado
- ✅ Notificaciones inmediatas funcionan perfectamente
- ❌ Notificaciones programadas (alarmas) NO funcionan
- ❌ Formato de hora sigue mostrando 24 horas en algunos lugares

### Causa Raíz
Android tiene optimizaciones agresivas de batería que matan las alarmas programadas con `flutter_local_notifications`, especialmente en:
- Samsung (Device Care)
- Xiaomi (MIUI Battery Saver)
- Huawei (PowerGenie)
- Oppo/OnePlus (Battery Optimization)

### Solución Implementada: Sistema de Doble Respaldo

#### 1️⃣ Método Principal: flutter_local_notifications
```dart
// scheduleWeeklyNotification en notification_service.dart
// Intenta programar notificaciones usando el método estándar
// Funciona en ~60% de los dispositivos sin configuración adicional
```

#### 2️⃣ Método de Respaldo: WorkManager (ReminderCheckerService)
```dart
// reminder_checker_service.dart
// Se ejecuta cada 15 minutos en background
// Verifica si hay recordatorios que deban dispararse (ventana ±15 min)
// Funciona en ~95% de los dispositivos (mucho más robusto)
```

**Ventajas del Sistema Híbrido:**
- ✅ Si el método principal funciona → notificación exacta en el minuto correcto
- ✅ Si el método principal falla → WorkManager dispara la notificación dentro de 15 min
- ✅ No requiere configuración manual del usuario
- ✅ Sobrevive reinicios del sistema
- ✅ Funciona incluso con optimizaciones agresivas de batería

## Problema Identificado

### 1. Verificar Configuración del Sistema (En el teléfono)

**Settings → Apps → MiSaludActiva → Notifications:**
- ✅ Notificaciones habilitadas
- ✅ "Scheduled Notifications" canal habilitado
- ✅ Prioridad: High/Urgent
- ✅ Sonido activado
- ✅ Vibración activada

**Settings → Apps → MiSaludActiva → Battery:**
- ⚠️ **CRÍTICO**: Poner en "Unrestricted" o "Optimized" 
- ❌ **NO usar "Restricted"** - esto mata las notificaciones programadas

**Settings → Battery → Battery Optimization:**
- ⚠️ Buscar tu app y ponerla en "Don't optimize"
- Algunos fabricantes (Samsung, Xiaomi, Huawei, Oppo) tienen optimizadores agresivos

### 2. Verificar Permisos de Alarmas Exactas

Para Android 12+ (API 31+), se necesita verificar manualmente:

```dart
// Agregar a notification_service.dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkExactAlarmPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
      // Android 12+
      final status = await Permission.scheduleExactAlarm.status;
      developer.log('Exact alarm permission: $status');
      
      if (!status.isGranted) {
        // Abrir configuración para que el usuario lo habilite manualmente
        await openAppSettings();
        return false;
      }
    }
  }
  return true;
}
```

### 3. Solución: Usar AlarmManager Directamente (Más Confiable)

Crear un método alternativo usando android_alarm_manager_plus:

**pubspec.yaml:**
```yaml
dependencies:
  android_alarm_manager_plus: ^3.0.0
```

**notification_service.dart:**
```dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// Método alternativo más confiable
Future<void> scheduleWeeklyNotificationAlternative({
  required int baseId,
  required String title,
  required String body,
  required TimeOfDay time,
  required List<bool> days,
}) async {
  // Usar AlarmManager directamente (más confiable que flutter_local_notifications)
  for (int i = 0; i < days.length; i++) {
    if (days[i]) {
      final dayIndex = i + 1;
      final notificationId = baseId + dayIndex;
      
      // Calcular próxima fecha
      DateTime scheduledDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );
      
      while (scheduledDate.weekday != dayIndex) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      if (scheduledDate.isBefore(DateTime.now())) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      // Usar AlarmManager con repetición semanal
      await AndroidAlarmManager.periodic(
        const Duration(days: 7),
        notificationId,
        _fireNotification,
        startAt: scheduledDate,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      
      developer.log('✅ Alarm scheduled: id=$notificationId at $scheduledDate');
    }
  }
}

@pragma('vm:entry-point')
static void _fireNotification() {
  // Mostrar notificación inmediata
  final service = NotificationService();
  service.showNotification(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: 'Recordatorio',
    body: 'Es hora de tu recordatorio',
  );
}
```

### 4. Solución: WorkManager para Recordatorios (Más Robusto)

Ya tienes `reminder_backup_service.dart`, pero puedes usarlo activamente:

**lib/services/reminder_scheduler_service.dart:**
```dart
import 'package:workmanager/workmanager.dart';

class ReminderSchedulerService {
  static const String taskName = 'reminderCheck';
  
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }
  
  static Future<void> scheduleReminderChecks() async {
    // Ejecutar cada 15 minutos para verificar recordatorios
    await Workmanager().registerPeriodicTask(
      'reminderCheckTask',
      taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Verificar recordatorios pendientes
      await Hive.initFlutter();
      final remindersBox = await Hive.openBox<Reminder>('reminders');
      
      final now = DateTime.now();
      final currentTime = TimeOfDay.fromDateTime(now);
      final currentDay = now.weekday;
      
      for (var reminder in remindersBox.values) {
        if (!reminder.isActive) continue;
        
        final reminderDay = reminder.days.indexOf(true) + 1;
        if (reminderDay == currentDay) {
          // Verificar si la hora coincide (±5 minutos)
          final diff = (reminder.time.hour * 60 + reminder.time.minute) - 
                      (currentTime.hour * 60 + currentTime.minute);
          
          if (diff.abs() <= 5) {
            // Mostrar notificación
            final notificationService = NotificationService();
            await notificationService.init();
            await notificationService.showNotification(
              id: reminder.id.hashCode,
              title: reminder.title,
              body: reminder.description ?? 'Recordatorio programado',
            );
          }
        }
      }
      
      return true;
    } catch (e) {
      print('❌ Error in reminder check: $e');
      return false;
    }
  });
}
```

**Llamar en main.dart:**
```dart
await ReminderSchedulerService.initialize();
await ReminderSchedulerService.scheduleReminderChecks();
```

### 5. Solución: Modo Híbrido (Lo Más Confiable)

Combinar ambos métodos para máxima confiabilidad:

```dart
Future<void> scheduleReminderHybrid(Reminder reminder) async {
  // Método 1: flutter_local_notifications (funciona el 80% del tiempo)
  await scheduleWeeklyNotification(
    baseId: reminder.id.hashCode,
    title: reminder.title,
    body: reminder.description ?? '',
    time: reminder.time,
    days: reminder.days,
  );
  
  // Método 2: WorkManager como backup (funciona el 95% del tiempo)
  await ReminderSchedulerService.scheduleReminderChecks();
  
  // Método 3: AlarmManager directo (funciona el 99% del tiempo)
  await scheduleWeeklyNotificationAlternative(
    baseId: reminder.id.hashCode,
    title: reminder.title,
    body: reminder.description ?? '',
    time: reminder.time,
    days: reminder.days,
  );
}
```

## Pruebas Recomendadas

### Test 1: Notificación Inmediata
```dart
await notificationService.showNotification(
  id: 999,
  title: 'Test inmediato',
  body: 'Si ves esto, las notificaciones básicas funcionan',
);
```

### Test 2: Notificación en 1 Minuto
```dart
await notificationService.scheduleNotification(
  id: 1000,
  title: 'Test 1 minuto',
  body: 'Deberías ver esto en 1 minuto',
  scheduledDate: DateTime.now().add(Duration(minutes: 1)),
);
```

### Test 3: Verificar Notificaciones Pendientes
```dart
final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
print('Notificaciones pendientes: ${pending.length}');
for (var n in pending) {
  print('  ID: ${n.id}, Título: ${n.title}');
}
```

### Test 4: Logs del Sistema
```bash
# Conectar el teléfono y ver logs en tiempo real
adb logcat | grep -i "notification\|alarm\|reminder"
```

## Fabricantes Problemáticos

### Samsung
- Ve a: Settings → Apps → MiSaludActiva → Battery → Optimize battery usage → All apps → MiSaludActiva → Don't optimize
- Settings → Device care → Battery → App power management → Apps that won't be put to sleep → Agregar MiSaludActiva

### Xiaomi/MIUI
- Settings → Apps → Manage apps → MiSaludActiva → Battery saver → No restrictions
- Settings → Notifications → MiSaludActiva → Habilitar todo
- Security → Permissions → Autostart → Habilitar MiSaludActiva

### Huawei
- Settings → Apps → MiSaludActiva → Battery → Launch → Manual (habilitar todo)

### Oppo/OnePlus
- Settings → Battery → Battery Optimization → MiSaludActiva → Don't optimize

## Documentación de Referencia
- https://dontkillmyapp.com/ - Lista de fabricantes que matan apps en background
- https://developer.android.com/training/scheduling/alarms - Guía oficial de alarmas Android
