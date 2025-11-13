import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:uuid/uuid.dart';

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
      _selectedTime =
          TimeOfDay(hour: widget.reminder!.hour, minute: widget.reminder!.minute);
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
    final daysOfWeek = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repetir en:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            return _DayButton(
              label: daysOfWeek[index],
              isSelected: _selectedDays[index],
              onTap: () {
                setState(() {
                  _selectedDays[index] = !_selectedDays[index];
                });
              },
            );
          }),
        ),
      ],
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

  void _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final notificationService = NotificationService();
      final remindersBox = Hive.box<Reminder>('reminders');

      // Cancel old notifications if editing
      if (isEditing) {
        await notificationService.cancelWeeklyNotifications(widget.reminder!.id.hashCode, widget.reminder!.days);
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
        await notificationService.scheduleWeeklyNotification(
            reminder.id.hashCode, reminder.title, 'Es hora de tu hábito diario.', _selectedTime, _selectedDays);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isEditing
                  ? 'Recordatorio actualizado'
                  : 'Recordatorio guardado')),
        );
        Navigator.pop(context);
      }
    }
  }
}

class _DayButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(100),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
