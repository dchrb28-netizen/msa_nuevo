import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/screens/training/select_exercise_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/routine_provider.dart';

class EditRoutineScreen extends StatefulWidget {
  final String? routineId;

  const EditRoutineScreen({super.key, this.routineId});

  @override
  State<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends State<EditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Local UI state variables
  late String _routineName;
  late String _routineDescription;
  late List<RoutineExercise> _routineExercises;
  Routine? _existingRoutine; // The original routine object for updates
  bool _isCreating = true;

  @override
  void initState() {
    super.initState();
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);

    if (widget.routineId != null) {
      // *** EDITING FLOW ***
      _isCreating = false;
      // 1. Find the fully loaded routine from the provider.
      _existingRoutine = routineProvider.routines.firstWhere((r) => r.id == widget.routineId!);
      
      // 2. Populate local state from the existing routine.
      _routineName = _existingRoutine!.name;
      _routineDescription = _existingRoutine!.description;
      // 3. Create a mutable copy of the exercises for the UI to manipulate.
      _routineExercises = List<RoutineExercise>.from(_existingRoutine!.exercises ?? []);
    } else {
      // *** CREATION FLOW ***
      _isCreating = true;
      _routineName = '';
      _routineDescription = '';
      _routineExercises = []; // Start with an empty list.
    }
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);

    try {
      if (_isCreating) {
        // 1. Create the routine object first.
        final newRoutine = await routineProvider.addRoutine(_routineName, _routineDescription);
        // 2. Now update the new routine with the list of exercises from UI state.
        await routineProvider.updateRoutine(newRoutine, _routineExercises);
      } else {
        // 1. Update the original routine object with the new name/description.
        _existingRoutine!.name = _routineName;
        _existingRoutine!.description = _routineDescription;
        // 2. Pass the original routine and the updated exercise list to the provider.
        await routineProvider.updateRoutine(_existingRoutine!, _routineExercises);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al guardar: $e'))
          );
      }
    }
  }

  void _navigateAndSelectExercise() async {
    final selectedExercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (context) => const SelectExerciseScreen(),
      ),
    );

    if (selectedExercise != null) {
      _showExerciseSettingsDialog(exercise: selectedExercise);
    }
  }

  void _showExerciseSettingsDialog({required Exercise exercise, RoutineExercise? routineExercise, int? index}) {
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
        title: Text(_isCreating ? 'Crear Rutina' : 'Editar Rutina'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRoutine,
          ),
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
                            subtitle: Text('${routineExercise.sets} series x ${routineExercise.reps} reps'),
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
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
        // If editing, we update the existing instance.
        routineExerciseToSave = widget.routineExercise!;
        routineExerciseToSave.sets = _sets;
        routineExerciseToSave.reps = _reps;
        routineExerciseToSave.weight = _weight;
        routineExerciseToSave.restTime = _restTime;
        // Ensure the exercise object is carried over
        routineExerciseToSave.setExercise(widget.exercise);
      } else {
        // If creating, we make a new instance.
        routineExerciseToSave = RoutineExercise(
          exerciseId: widget.exercise.id,
          sets: _sets,
          reps: _reps,
          weight: _weight,
          restTime: _restTime,
        );
         // Ensure the exercise object is attached immediately
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
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _sets = int.parse(value!),
              ),
              TextFormField(
                initialValue: _reps,
                decoration: const InputDecoration(labelText: 'Repeticiones (ej. 8-12)'),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  if (double.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _weight = (value == null || value.isEmpty) ? null : double.tryParse(value),
              ),
              TextFormField(
                initialValue: _restTime?.toString() ?? '',
                decoration: const InputDecoration(labelText: 'Descanso (segundos, opcional)'),
                keyboardType: TextInputType.number,
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  if (int.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _restTime = (value == null || value.isEmpty) ? null : int.tryParse(value),
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
        ElevatedButton(
          onPressed: _onSave,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
