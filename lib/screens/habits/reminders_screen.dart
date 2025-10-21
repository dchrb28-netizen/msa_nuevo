
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/screens/habits/add_reminder_screen.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final remindersBox = Hive.box<Reminder>('reminders');
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Reminder> _reminders;

  @override
  void initState() {
    super.initState();
    _reminders = remindersBox.values.toList();
    remindersBox.listenable().addListener(_onHiveBoxChanged);
  }

  @override
  void dispose() {
    remindersBox.listenable().removeListener(_onHiveBoxChanged);
    super.dispose();
  }

  void _onHiveBoxChanged() {
    final newReminders = remindersBox.values.toList();

    // Handle removals
    for (int i = _reminders.length - 1; i >= 0; i--) {
      if (!newReminders.any((r) => r.id == _reminders[i].id)) {
        final removedReminder = _reminders.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildRemovedItem(removedReminder, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    // Handle additions
    for (int i = 0; i < newReminders.length; i++) {
      if (!_reminders.any((r) => r.id == newReminders[i].id)) {
        _reminders.insert(i, newReminders[i]);
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 300));
      }
    }

    // Handle updates by rebuilding the state
    setState(() {
      _reminders = newReminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _reminders.isEmpty
          ? const Center(child: Text('Aún no tienes recordatorios.'))
          : AnimatedList(
              key: _listKey,
              initialItemCount: _reminders.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index, animation) {
                // Check for index out of bounds
                if (index >= _reminders.length) return const SizedBox.shrink();
                final reminder = _reminders[index];
                return _buildItem(reminder, animation);
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

  Widget _buildItem(Reminder reminder, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Dismissible(
          key: Key(reminder.id),
          onDismissed: (direction) {
            _deleteReminder(reminder);
          },
          confirmDismiss: (direction) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Confirmar Eliminación'),
                  content: Text('¿Estás seguro de que quieres eliminar el recordatorio "${reminder.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
                  ],
                );
              },
            );
            return confirmed ?? false;
          },
          background: Container(
            color: Colors.red.shade700,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            leading: const Icon(Icons.alarm, size: 30),
            title: Text(reminder.title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text('${_formatDays(reminder.days)} a las ${reminder.hour}:${reminder.minute.toString().padLeft(2, '0')}'),
            trailing: Switch(
              value: reminder.isActive,
              onChanged: (bool value) {
                _toggleReminder(reminder, value);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddReminderScreen(reminder: reminder)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRemovedItem(Reminder reminder, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        elevation: 0,
        color: Colors.red.shade100,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: ListTile(
          title: Text(reminder.title, style: const TextStyle(decoration: TextDecoration.lineThrough)),
        ),
      ),
    );
  }

  void _deleteReminder(Reminder reminder) {
    for (int i = 0; i < reminder.days.length; i++) {
      if (reminder.days[i]) {
        NotificationService().flutterLocalNotificationsPlugin.cancel(reminder.id.hashCode + i);
      }
    }
    // We need the index *before* deleting to notify the AnimatedList
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminder.delete(); // This will trigger the listener, which will handle the animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recordatorio "${reminder.title}" eliminado')),
      );
    }
  }
  
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void _toggleReminder(Reminder reminder, bool isActive) {
    reminder.isActive = isActive;
    reminder.save(); // This will trigger the listener and a setState to update the UI

    final notificationService = NotificationService();
    if (isActive) {
      final scheduledDate = _nextInstanceOfTime(reminder.hour, reminder.minute);
      for (int i = 0; i < reminder.days.length; i++) {
        if (reminder.days[i]) {
          notificationService.scheduleDailyNotification(
            id: reminder.id.hashCode + i,
            title: 'Recordatorio de Hábito',
            body: reminder.title,
            scheduledDate: scheduledDate,
          );
        }
      }
    } else {
      for (int i = 0; i < reminder.days.length; i++) {
        if (reminder.days[i]) {
          notificationService.flutterLocalNotificationsPlugin.cancel(reminder.id.hashCode + i);
        }
      }
    }
  }

  String _formatDays(List<bool> days) {
    const dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    if (days.every((d) => d)) return 'Todos los días';
    if (days.every((d) => !d)) return 'Nunca';

    final selectedDays = <String>[];
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        selectedDays.add(dayNames[i]);
      }
    }
    return selectedDays.join(', ');
  }
}
