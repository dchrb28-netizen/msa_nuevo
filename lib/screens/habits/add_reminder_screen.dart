import 'package:flutter/foundation.dart';
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
      _selectedTime = TimeOfDay(
        hour: widget.reminder!.hour,
        minute: widget.reminder!.minute,
      );
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

      // Check for duplicates (same time + same days) except when editing the same reminder
      Reminder? existingDuplicate;
      try {
        existingDuplicate = remindersBox.values.firstWhere(
          (r) =>
              r.id != (isEditing ? widget.reminder!.id : null) &&
              r.hour == _selectedTime.hour &&
              r.minute == _selectedTime.minute &&
              listEquals(r.days, _selectedDays),
        );
      } catch (e) {
        existingDuplicate = null;
      }

      if (existingDuplicate != null) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Duplicado detectado'),
            content: const Text(
              'Ya existe un recordatorio a la misma hora y días. ¿Deseas crear otro igual?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Crear'),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }

      // Cancel old notifications if editing
      if (isEditing) {
        await notificationService.cancelWeeklyNotifications(
          widget.reminder!.id.hashCode,
          widget.reminder!.days,
        );
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
        try {
          await notificationService.scheduleWeeklyNotification(
            reminder.id.hashCode,
            reminder.title,
            'Es hora de tu hábito diario.',
            _selectedTime,
            _selectedDays,
          );
        } catch (e) {
          // If scheduling fails, deactivate the reminder and inform the user
          await remindersBox.put(
            reminder.id,
            reminder.copyWith(isActive: false),
          );
          if (mounted) {
            await showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error al programar'),
                content: Text('No se pudo programar la notificación: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            );
          }
        }
      }

      if (mounted) {
        // Show a confirmation dialog.
        // It's safe to use the context here because it's before the await.
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              isEditing ? 'Recordatorio actualizado' : 'Recordatorio guardado',
            ),
            content: const Text('Tu recordatorio se guardó correctamente.'),
            actions: [
              // Use the dialog's context to pop the dialog.
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );

        // After the await, check if the widget is still mounted before using its context.
        if (mounted) {
          Navigator.of(context).pop(); // Pop the AddReminderScreen itself.
        }
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
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(100),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
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
