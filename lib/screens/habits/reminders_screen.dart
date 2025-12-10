import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/screens/habits/add_reminder_screen.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/foreground_reminder_service.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    final isRunning = await ForegroundReminderService.isRunning();
    if (mounted) {
      setState(() {
        _isServiceRunning = isRunning;
      });
    }
  }

  Future<void> _toggleService() async {
    if (_isServiceRunning) {
      await ForegroundReminderService.stop();
      if (mounted) {
        setState(() {
          _isServiceRunning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏹️ Servicio desactivado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      await ForegroundReminderService.start();
      if (mounted) {
        setState(() {
          _isServiceRunning = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('▶️ Servicio activado\nNotificaciones exactas'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se vuelve a usar un Scaffold para poder alojar el FloatingActionButton.
    return Scaffold(
      body: Column(
        children: [
          // Banner informativo
          if (!_isServiceRunning)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade900),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Para que las notificaciones lleguen a la hora exacta, activa el servicio con el botón verde ▶️',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Reminder>('reminders').listenable(),
              builder: (context, Box<Reminder> box, _) {
                final reminders = box.values.toList();
                if (reminders.isEmpty) {
                  return Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.2,
                          child: Image.asset(
                            Theme.of(context).brightness == Brightness.dark
                                ? 'assets/luna_png/luna_recordatorios_b.png'
                                : 'assets/luna_png/luna_recordatorios_w.png',
                            height: 250,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'Aún no has creado ningún recordatorio. ¡Toca el botón (+) para empezar!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Stack(
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    80,
                  ), // Padding inferior para que el FAB no tape el último elemento
                  itemCount: reminders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return _ReminderCard(
                      reminder: reminder,
                      onServiceStateChanged: _checkServiceStatus,
                    );
                  },
                ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 160,
            height: 56,
            child: FloatingActionButton.extended(
              heroTag: 'foreground_service',
              onPressed: _toggleService,
              backgroundColor: _isServiceRunning ? Colors.green : Colors.grey.shade600,
              tooltip: _isServiceRunning ? 'Parar servicio' : 'Activar servicio',
              icon: Icon(_isServiceRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
              label: Text(_isServiceRunning ? 'Parar' : 'Activar'),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'add_reminder',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddReminderScreen()),
              );
            },
            tooltip: 'Añadir Recordatorio',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onServiceStateChanged;

  const _ReminderCard({
    required this.reminder,
    required this.onServiceStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (bool value) async {
                    final notificationService = NotificationService();
                    
                    // Si se está activando, verificar permisos primero
                    if (value) {
                      final hasPermissions = await notificationService.checkAndRequestPermissions();
                      
                      if (!hasPermissions) {
                        // Mostrar diálogo de permisos
                        if (context.mounted) {
                          await showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Permisos requeridos'),
                              content: const Text(
                                'Para activar recordatorios, necesitas habilitar los permisos de notificaciones y alarmas exactas.\n\n'
                                'Ve a: Configuración > Aplicaciones > MiSaludActiva > Permisos',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    openAppSettings();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Abrir Configuración'),
                                ),
                              ],
                            ),
                          );
                        }
                        return; // No cambiar el estado del switch
                      }
                    }
                    
                    final updatedReminder = reminder.copyWith(isActive: value);
                    await Hive.box<Reminder>(
                      'reminders',
                    ).put(reminder.id, updatedReminder);

                    final time = TimeOfDay(
                      hour: reminder.hour,
                      minute: reminder.minute,
                    );
                    
                    if (value) {
                      try {
                        await notificationService.scheduleWeeklyNotification(
                          reminder.id.hashCode,
                          reminder.title,
                          'Es hora de tu hábito diario.',
                          time,
                          reminder.days,
                        );
                        
                        // Auto-iniciar el servicio foreground si no está corriendo
                        final isServiceRunning = await ForegroundReminderService.isRunning();
                        if (!isServiceRunning) {
                          await ForegroundReminderService.start();
                          onServiceStateChanged(); // Actualizar UI del padre
                        }
                        
                        // Mostrar confirmación
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ Recordatorio "${reminder.title}" activado\n🚀 Servicio de notificaciones iniciado'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e) {
                        // Revertir el cambio si falla
                        await Hive.box<Reminder>(
                          'reminders',
                        ).put(reminder.id, reminder.copyWith(isActive: false));
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Error al activar: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } else {
                      await notificationService.cancelWeeklyNotifications(
                        reminder.id.hashCode,
                        reminder.days,
                      );
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Recordatorio "${reminder.title}" desactivado'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(context),
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDaysRow(context, reminder.days),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 22),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddReminderScreen(reminder: reminder),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 22),
                  onPressed: () => _confirmDelete(context, reminder),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(BuildContext context) {
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
    final timeFormatService = Provider.of<TimeFormatService>(context, listen: false);
    return timeFormatService.formatTimeOfDay(time, context);
  }

  void _confirmDelete(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este recordatorio?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await Hive.box<Reminder>('reminders').delete(reminder.id);
                await NotificationService().cancelWeeklyNotifications(
                  reminder.id.hashCode,
                  reminder.days,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recordatorio eliminado')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDaysRow(BuildContext context, List<bool> days) {
    final daysOfWeek = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(days.length, (index) {
        return _DayIndicator(day: daysOfWeek[index], isSelected: days[index]);
      }),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final String day;
  final bool isSelected;

  const _DayIndicator({required this.day, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
