import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/foreground_reminder_service.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
  late int _repeatMinutes;

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
      _repeatMinutes = widget.reminder!.repeatMinutes;
    } else {
      _titleController = TextEditingController();
      _selectedTime = TimeOfDay.now();
      _selectedDays = List.filled(7, true);
      _repeatMinutes = 0;
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
        // title removed
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
                trailing: Text(
                  Provider.of<TimeFormatService>(context).formatTimeOfDay(_selectedTime, context),
                ),
                onTap: _pickTime,
              ),
              const SizedBox(height: 20),
              _buildRepeatSelector(),
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

  Widget _buildRepeatSelector() {
    final predefinedMinutes = [0, 5, 10, 15, 30, 60];
    final isCustom = !predefinedMinutes.contains(_repeatMinutes);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repetir cada:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('No repetir'),
                  selected: _repeatMinutes == 0,
                  onSelected: (selected) {
                    if (selected) setState(() => _repeatMinutes = 0);
                  },
                ),
                ChoiceChip(
                  label: const Text('5 min'),
                  selected: _repeatMinutes == 5,
                  onSelected: (selected) {
                    if (selected) setState(() => _repeatMinutes = 5);
                  },
                ),
                ChoiceChip(
                  label: const Text('10 min'),
                  selected: _repeatMinutes == 10,
                  onSelected: (selected) {
                    if (selected) setState(() => _repeatMinutes = 10);
                  },
                ),
                ChoiceChip(
                  label: const Text('15 min'),
                  selected: _repeatMinutes == 15,
                  onSelected: (selected) {
                    if (selected) setState(() => _repeatMinutes = 15);
                  },
                ),
                ChoiceChip(
                  label: const Text('30 min'),
                  selected: _repeatMinutes == 30,
                  onSelected: (selected) {
                    if (selected) setState(() => _repeatMinutes = 30);
                  },
                ),
                ChoiceChip(
                  label: const Text('60 min'),
                  selected: _repeatMinutes == 60,
                  onSelected: (selected) {
                    if (selected) setState(() => _repeatMinutes = 60);
                  },
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.edit, size: 18),
                  label: Text(isCustom 
                    ? _formatCustomTime(_repeatMinutes)
                    : 'Personalizar'),
                  selected: isCustom,
                  onSelected: (selected) {
                    _showCustomTimeDialog();
                  },
                ),
              ],
            ),
            if (_repeatMinutes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'ℹ️ Se repetirá cada ${_formatCustomTime(_repeatMinutes)} hasta el final del día',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatCustomTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return '$hours ${hours == 1 ? 'hora' : 'horas'}';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours${mins > 0 ? '.5' : ''} ${hours == 1 && mins == 0 ? 'hora' : 'horas'}';
    }
  }

  Future<void> _showCustomTimeDialog() async {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    
    // Si hay un valor personalizado actual, mostrarlo
    if (_repeatMinutes > 0) {
      final hours = _repeatMinutes ~/ 60;
      final mins = _repeatMinutes % 60;
      if (hours > 0) hoursController.text = hours.toString();
      if (mins > 0) minutesController.text = mins.toString();
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tiempo personalizado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el tiempo de repetición:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Horas',
                      border: OutlineInputBorder(),
                      hintText: '0',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minutos',
                      border: OutlineInputBorder(),
                      hintText: '0',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ejemplos: 1h 30min, 2h 0min, 0h 90min',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final hours = int.tryParse(hoursController.text) ?? 0;
              final minutes = int.tryParse(minutesController.text) ?? 0;
              final totalMinutes = (hours * 60) + minutes;
              
              if (totalMinutes > 0) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un valor mayor a 0'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final hours = int.tryParse(hoursController.text) ?? 0;
      final minutes = int.tryParse(minutesController.text) ?? 0;
      final totalMinutes = (hours * 60) + minutes;
      
      setState(() {
        _repeatMinutes = totalMinutes;
      });
    }
    
    hoursController.dispose();
    minutesController.dispose();
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
    final timeFormatService = Provider.of<TimeFormatService>(context, listen: false);
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: timeFormatService.use24HourFormat,
          ),
          child: Localizations.override(
            context: context,
            locale: timeFormatService.use24HourFormat 
                ? const Locale('es', 'ES') 
                : const Locale('en', 'US'),
            child: child!,
          ),
        );
      },
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
        repeatMinutes: _repeatMinutes,
      );

      await remindersBox.put(reminder.id, reminder);

      // Schedule new notifications if active
      if (reminder.isActive) {
        // Verificar permisos antes de programar
        final hasPermissions = await notificationService.checkAndRequestPermissions();
        
        if (!hasPermissions) {
          // Desactivar el recordatorio si no hay permisos
          await remindersBox.put(
            reminder.id,
            reminder.copyWith(isActive: false),
          );
          
          if (mounted) {
            await showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permisos requeridos'),
                content: const Text(
                  'Para programar recordatorios, necesitas habilitar los permisos de notificaciones y alarmas exactas en la configuración de tu dispositivo.\n\n'
                  'Ve a: Configuración > Aplicaciones > MiSaludActiva > Permisos',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Entendido'),
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
          return;
        }
        
        try {
          // Log detallado de lo que se está programando
          debugPrint('📅 PROGRAMANDO RECORDATORIO:');
          debugPrint('  - Título: ${reminder.title}');
          debugPrint('  - Hora: ${_selectedTime.hour}:${_selectedTime.minute}');
          debugPrint('  - Días seleccionados: $_selectedDays');
          debugPrint('  - ID base: ${reminder.id.hashCode}');
          
          await notificationService.scheduleWeeklyNotification(
            reminder.id.hashCode,
            reminder.title,
            'Es hora de tu hábito diario.',
            _selectedTime,
            _selectedDays,
          );
          
          // Log de confirmación
          if (mounted) {
            debugPrint('✅ Recordatorio programado: ${reminder.title} a las ${Provider.of<TimeFormatService>(context, listen: false).formatTimeOfDay(_selectedTime, context)}');
          }
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
                content: Text('No se pudo programar la notificación: $e\n\nAsegúrate de que los permisos estén habilitados en la configuración del sistema.'),
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
          return;
        }
      }

      // Reiniciar el servicio foreground para que recargue los recordatorios
      if (reminder.isActive) {
        final isServiceRunning = await ForegroundReminderService.isRunning();
        if (isServiceRunning) {
          // Reiniciar el servicio para recargar los recordatorios
          await ForegroundReminderService.stop();
          await Future.delayed(const Duration(milliseconds: 500));
          await ForegroundReminderService.start();
          debugPrint('🔄 Servicio foreground reiniciado para recargar recordatorios');
        } else {
          // Iniciar el servicio por primera vez
          await ForegroundReminderService.start();
          debugPrint('🚀 Servicio foreground iniciado después de crear recordatorio');
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
            content: Text(
              reminder.isActive 
                ? 'Tu recordatorio se guardó correctamente.\n\n✅ El servicio de notificaciones exactas está activo.'
                : 'Tu recordatorio se guardó correctamente.',
            ),
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
