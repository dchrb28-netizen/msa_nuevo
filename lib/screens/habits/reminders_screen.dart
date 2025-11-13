import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/screens/habits/add_reminder_screen.dart';
import 'package:myapp/services/notification_service.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recordatorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddReminderScreen(),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Reminder>('reminders').listenable(),
        builder: (context, Box<Reminder> box, _) {
          final reminders = box.values.toList();
          if (reminders.isEmpty) {
            return const Center(
              child: Text('Aún no has creado ningún recordatorio.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _ReminderCard(reminder: reminder);
            },
          );
        },
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;

  const _ReminderCard({required this.reminder});

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
                Text(
                  reminder.title,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (bool value) async {
                    final updatedReminder = reminder.copyWith(isActive: value);
                    await Hive.box<Reminder>('reminders')
                        .put(reminder.id, updatedReminder);

                    final notificationService = NotificationService();
                    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
                    if (value) {
                       await notificationService.scheduleWeeklyNotification(
                          reminder.id.hashCode, reminder.title, 'Es hora de tu hábito diario.', time, reminder.days);
                    } else {
                       await notificationService.cancelWeeklyNotifications(reminder.id.hashCode, reminder.days);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(context),
              style: textTheme.titleMedium?.copyWith(color: colorScheme.primary),
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
                      builder: (context) => AddReminderScreen(reminder: reminder),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 22),
                  onPressed: () => _confirmDelete(context, reminder),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatTime(BuildContext context) {
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
    return time.format(context);
  }

  void _confirmDelete(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este recordatorio?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await Hive.box<Reminder>('reminders').delete(reminder.id);
                await NotificationService().cancelWeeklyNotifications(reminder.id.hashCode, reminder.days);
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
