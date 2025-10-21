
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TimeOfDay _selectedTime;
  late List<bool> _selectedDays;

  bool get isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController = TextEditingController(text: widget.reminder!.title);
      _selectedTime = TimeOfDay(hour: widget.reminder!.hour, minute: widget.reminder!.minute);
      _selectedDays = List.from(widget.reminder!.days);
    } else {
      _titleController = TextEditingController();
      _selectedTime = TimeOfDay.now();
      _selectedDays = List.filled(7, true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Recordatorio' : 'Nuevo Recordatorio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del Recordatorio',
                  border: OutlineInputBorder(),
                  hintText: 'Ej. Beber Agua',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Hora'),
                trailing: Text(_selectedTime.format(context)),
                onTap: _pickTime,
              ),
              const SizedBox(height: 20),
              const Text('Repetir en:'),
              _buildDaySelector(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveReminder,
                child: Text(isEditing ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        return ChoiceChip(
          label: Text(days[index]),
          selected: _selectedDays[index],
          onSelected: (selected) {
            setState(() {
              _selectedDays[index] = selected;
            });
          },
        );
      }),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
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

  void _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final notificationService = NotificationService();
      final remindersBox = Hive.box<Reminder>('reminders');

      // Cancel old notifications if editing
      if (isEditing) {
        final oldReminder = widget.reminder!;
        for (int i = 0; i < oldReminder.days.length; i++) {
          if (oldReminder.days[i]) {
            notificationService.flutterLocalNotificationsPlugin.cancel(oldReminder.id.hashCode + i);
          }
        }
      }

      final reminderId = isEditing ? widget.reminder!.id : const Uuid().v4();
      final title = _titleController.text;

      final reminder = Reminder(
        id: reminderId,
        title: title,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        days: _selectedDays,
        isActive: isEditing ? widget.reminder!.isActive : true,
      );

      await remindersBox.put(reminder.id, reminder);

      // Schedule new notifications if active
      if (reminder.isActive) {
        final scheduledDate = _nextInstanceOfTime(_selectedTime.hour, _selectedTime.minute);
        for (int i = 0; i < _selectedDays.length; i++) {
          if (_selectedDays[i]) {
            // The notification service will match the time component daily.
            // We schedule it for the next upcoming time.
            await notificationService.scheduleDailyNotification(
              id: reminder.id.hashCode + i,
              title: 'Recordatorio de Hábito',
              body: title,
              scheduledDate: scheduledDate,
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Recordatorio actualizado' : 'Recordatorio guardado')),
        );
        Navigator.pop(context);
      }
    }
  }
}
