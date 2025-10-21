import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/screens/habits/add_reminder_screen.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remindersBox = Hive.box<Reminder>('reminders');

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: remindersBox.listenable(),
        builder: (context, Box<Reminder> box, _) {
          final reminders = box.values.toList();
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No hay recordatorios',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Crea tu primer recordatorio para mantenerte al día con tus hábitos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _ReminderCard(
                  reminder: reminder,
                  notificationService: _notificationService,
                  theme: theme);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final NotificationService notificationService;
  final ThemeData theme;

  const _ReminderCard({
    required this.reminder,
    required this.notificationService,
    required this.theme,
  });

  String _formatDays(List<bool> days) {
    if (days.every((d) => d)) return 'Todos los días';
    if (days.every((d) => !d)) return 'Nunca';

    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final selectedDays = <String>[];
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        selectedDays.add(dayNames[i]);
      }
    }
    return selectedDays.join(', ');
  }

  void _toggleReminder(bool isActive) async {
    reminder.isActive = isActive;
    await reminder.save();

    if (isActive) {
       await notificationService.scheduleDailyNotification(
          reminder.id.hashCode, reminder.title, 'Es hora de tu hábito diario.', TimeOfDay(hour: reminder.hour, minute: reminder.minute));
    } else {
      await notificationService.cancelNotification(reminder.id.hashCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm('es_ES');
    final time = DateTime(2023, 1, 1, reminder.hour, reminder.minute);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Text(
                  reminder.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: _toggleReminder,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              timeFormat.format(time),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDays(reminder.days),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddReminderScreen(reminder: reminder),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content:
              const Text('¿Estás seguro de que quieres eliminar este recordatorio?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                // Cancel all notifications for this reminder
                notificationService.cancelNotification(reminder.id.hashCode);
                reminder.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
