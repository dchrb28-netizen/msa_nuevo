import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/select_exercise_screen.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:provider/provider.dart';

class EditRoutineScreen extends StatefulWidget {
  final String? routineId;

  const EditRoutineScreen({super.key, this.routineId});

  @override
  State<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends State<EditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _routineName;
  late String _routineDescription;
  late String? _dayOfWeek; // Mantener para compatibilidad
  late List<bool> _selectedDays; // Nuevo: Lun, Mar, Mié, Jue, Vie, Sáb, Dom
  late List<RoutineExercise> _routineExercises;
  Routine? _existingRoutine;
  bool _isCreating = true;

  final List<String> _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);

    if (widget.routineId != null) {
      _isCreating = false;
      _existingRoutine = routineProvider.routines.firstWhere((r) => r.id == widget.routineId!);
      _routineName = _existingRoutine!.name;
      _routineDescription = _existingRoutine!.description;
      _dayOfWeek = _existingRoutine!.dayOfWeek;
      
      // Inicializar días seleccionados desde activeDays
      _selectedDays = List.generate(7, (index) {
        final activeDays = _existingRoutine!.activeDays;
        return activeDays.contains(_days[index]);
      });
      
      _routineExercises = List<RoutineExercise>.from(_existingRoutine!.exercises ?? []);
    } else {
      _isCreating = true;
      _routineName = '';
      _routineDescription = '';
      _dayOfWeek = null;
      _selectedDays = List.generate(7, (_) => false); // Ningún día seleccionado por defecto
      _routineExercises = [];
    }
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    // Obtener días seleccionados
    final selectedDayNames = <String>[];
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        selectedDayNames.add(_days[i]);
      }
    }

    // Capture context-dependent services BEFORE the async gap.
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    final achievementService = Provider.of<AchievementService>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      debugPrint('[EditRoutine] _saveRoutine: saving routine "$_routineName" isCreating=$_isCreating');
      if (_isCreating) {
        final newRoutine = await routineProvider.addRoutine(
          _routineName,
          _routineDescription,
          selectedDayNames.isNotEmpty ? selectedDayNames.first : null,
        );
        // Actualizar con múltiples días
        newRoutine.daysOfWeek = selectedDayNames.isNotEmpty ? selectedDayNames : null;
        await routineProvider.updateRoutine(newRoutine, _routineExercises);
        achievementService.updateProgress('create_routine', 1);
      } else {
        _existingRoutine!.name = _routineName;
        _existingRoutine!.description = _routineDescription;
        _existingRoutine!.daysOfWeek = selectedDayNames.isNotEmpty ? selectedDayNames : null;
        // Mantener dayOfWeek para compatibilidad
        _existingRoutine!.dayOfWeek = selectedDayNames.isNotEmpty ? selectedDayNames.first : null;
        await routineProvider.updateRoutine(_existingRoutine!, _routineExercises);
      }
      // Check `mounted` before using the navigator
        if (mounted) {
          debugPrint('[EditRoutine] _saveRoutine: pop after save');
          navigator.pop();
        }

    } catch (e) {
      // Check `mounted` before using the messenger
      if (mounted) messenger.showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  void _navigateAndSelectExercise() async {
    final selectedExercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(builder: (context) => const SelectExerciseScreen()),
    );

    if (selectedExercise != null) {
      if (!mounted) return;
      _showExerciseSettingsDialog(exercise: selectedExercise);
    }
  }

  void _showExerciseSettingsDialog({
    required Exercise exercise,
    RoutineExercise? routineExercise,
    int? index,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return ExerciseSettingsDialog(
          exercise: exercise,
          routineExercise: routineExercise,
          onSave: (newRoutineExercise) {
            setState(() {
              if (index != null) {
                _routineExercises[index] = newRoutineExercise;
              } else {
                _routineExercises.add(newRoutineExercise);
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title removed
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveRoutine),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _routineName,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la rutina',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre para la rutina';
                  }
                  return null;
                },
                onSaved: (value) => _routineName = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _routineDescription,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _routineDescription = value ?? '',
              ),
              const SizedBox(height: 16),
              Text(
                'Días de la semana (opcional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildDaysSelector(),
              const SizedBox(height: 24),
              Text('Ejercicios', style: Theme.of(context).textTheme.titleLarge),
              Expanded(
                child: _routineExercises.isEmpty
                    ? const Center(child: Text('Añade ejercicios a tu rutina.'))
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 80.0),
                        itemCount: _routineExercises.length,
                        itemBuilder: (context, index) {
                          final routineExercise = _routineExercises[index];
                          return ListTile(
                            key: ValueKey(routineExercise.hashCode),
                            title: Text(routineExercise.exercise.name),
                            subtitle: Text(
                              '${routineExercise.sets} series x ${routineExercise.reps} reps',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _showExerciseSettingsDialog(
                                    exercise: routineExercise.exercise,
                                    routineExercise: routineExercise,
                                    index: index,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _routineExercises.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = _routineExercises.removeAt(oldIndex);
                            _routineExercises.insert(newIndex, item);
                          });
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAndSelectExercise,
        label: const Text('Añadir Ejercicio'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDaysSelector() {
    final daysShort = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDays[index] = !_selectedDays[index];
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _selectedDays[index]
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                daysShort[index],
                style: TextStyle(
                  color: _selectedDays[index]
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: _selectedDays[index] ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ExerciseSettingsDialog extends StatefulWidget {
  final Exercise exercise;
  final RoutineExercise? routineExercise;
  final Function(RoutineExercise) onSave;

  const ExerciseSettingsDialog({
    super.key,
    required this.exercise,
    this.routineExercise,
    required this.onSave,
  });

  @override
  State<ExerciseSettingsDialog> createState() => _ExerciseSettingsDialogState();
}

class _ExerciseSettingsDialogState extends State<ExerciseSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _sets;
  late String _reps;
  late double? _weight;
  late int? _restTime;

  @override
  void initState() {
    super.initState();
    _sets = widget.routineExercise?.sets ?? 3;
    _reps = widget.routineExercise?.reps ?? '8-12';
    _weight = widget.routineExercise?.weight;
    _restTime = widget.routineExercise?.restTime;
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final RoutineExercise routineExerciseToSave;
      if (widget.routineExercise != null) {
        routineExerciseToSave = widget.routineExercise!;
        routineExerciseToSave.sets = _sets;
        routineExerciseToSave.reps = _reps;
        routineExerciseToSave.weight = _weight;
        routineExerciseToSave.restTime = _restTime;
        routineExerciseToSave.setExercise(widget.exercise);
      } else {
        routineExerciseToSave = RoutineExercise(
          exerciseId: widget.exercise.id,
          sets: _sets,
          reps: _reps,
          weight: _weight,
          restTime: _restTime,
        );
        routineExerciseToSave.setExercise(widget.exercise);
      }

      widget.onSave(routineExerciseToSave);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise.name),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _sets.toString(),
                decoration: const InputDecoration(labelText: 'Series'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _sets = int.parse(value!),
              ),
              TextFormField(
                initialValue: _reps,
                decoration: const InputDecoration(
                  labelText: 'Repeticiones (ej. 8-12)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce las repeticiones';
                  }
                  return null;
                },
                onSaved: (value) => _reps = value!,
              ),
              TextFormField(
                initialValue: _weight?.toString() ?? '',
                decoration: const InputDecoration(labelText: 'Peso (opcional)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  if (double.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _weight = (value == null || value.isEmpty)
                    ? null
                    : double.tryParse(value),
              ),
              TextFormField(
                initialValue: _restTime?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Descanso (segundos, opcional)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  if (int.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _restTime = (value == null || value.isEmpty)
                    ? null
                    : int.tryParse(value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _onSave, child: const Text('Guardar')),
      ],
    );
  }
}
