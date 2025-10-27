import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/screens/training/select_exercise_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:uuid/uuid.dart';

class EditRoutineScreen extends StatefulWidget {
  final Routine? routine;

  const EditRoutineScreen({super.key, this.routine});

  @override
  State<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends State<EditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _routineName;
  late String _routineDescription;
  late HiveList<RoutineExercise> _routineExercises;

  @override
  void initState() {
    super.initState();
    _routineName = widget.routine?.name ?? '';
    _routineDescription = widget.routine?.description ?? '';
    _routineExercises = widget.routine?.exercises ?? HiveList(Hive.box<RoutineExercise>('routine_exercises'));
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
      final routineBox = Hive.box<Routine>('routines');

      if (widget.routine == null) {
        // Creating a new routine
        final newRoutine = Routine(
          id: const Uuid().v4(),
          name: _routineName,
          description: _routineDescription,
        );
        // The HiveList needs to be associated with a saved routine
        routineBox.put(newRoutine.id, newRoutine).then((_){
            newRoutine.exercises.addAll(_routineExercises);
            newRoutine.save();
            routineProvider.addRoutine(newRoutine);
        });

      } else {
        // Updating an existing routine
        final existingRoutine = widget.routine!;
        existingRoutine.name = _routineName;
        existingRoutine.description = _routineDescription;
        
        // Clear and add new exercises to handle updates, additions, and deletions
        existingRoutine.exercises.clear();
        existingRoutine.exercises.addAll(_routineExercises);
        
        routineProvider.updateRoutine(existingRoutine.id, existingRoutine);
      }

      if (mounted) {
        Navigator.of(context).pop();
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
             final routineExerciseBox = Hive.box<RoutineExercise>('routine_exercises');
             routineExerciseBox.add(newRoutineExercise); // Save to its own box first

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
        title: Text(widget.routine == null ? 'Crear Rutina' : 'Editar Rutina'),
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
                        itemCount: _routineExercises.length,
                        itemBuilder: (context, index) {
                          final routineExercise = _routineExercises[index];
                          return ListTile(
                            key: ValueKey(routineExercise.key),
                            title: Text(routineExercise.exercise.name),
                            subtitle: Text('${routineExercise.sets} series x ${routineExercise.reps} reps'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  final item = _routineExercises.removeAt(index);
                                  item.delete(); // Remove from Hive box
                                });
                              },
                            ),
                            onTap: () => _showExerciseSettingsDialog(
                              exercise: routineExercise.exercise,
                              routineExercise: routineExercise,
                              index: index,
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
      
      // For updates, we modify the existing object. For new, we create one.
      final routineExercise = widget.routineExercise ?? RoutineExercise(exercise: widget.exercise, reps: _reps, sets: _sets);

      routineExercise.sets = _sets;
      routineExercise.reps = _reps;
      routineExercise.weight = _weight;
      routineExercise.restTime = _restTime;

      widget.onSave(routineExercise);
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
