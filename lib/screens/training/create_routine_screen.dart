import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/services/exercise_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _allExercises = [];
  final List<RoutineExercise> _selectedExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await _exerciseService.loadExercises();
    setState(() {
      _allExercises = exercises;
      _isLoading = false;
    });
  }

  void _toggleExerciseSelection(Exercise exercise) {
    setState(() {
      final existingExercise = _selectedExercises.firstWhere(
        (e) => e.exercise.id == exercise.id,
        orElse: () => RoutineExercise(exercise: exercise, sets: 3, reps: '10'),
      );

      if (_selectedExercises.any((e) => e.exercise.id == exercise.id)) {
        _selectedExercises.removeWhere((e) => e.exercise.id == exercise.id);
      } else {
        _selectedExercises.add(existingExercise);
      }
    });
  }

  void _saveRoutine() {
    Navigator.of(context).pop(_selectedExercises);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Rutina'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _selectedExercises.isNotEmpty ? _saveRoutine : null,
            tooltip: 'Guardar Rutina',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allExercises.length,
              itemBuilder: (context, index) {
                final exercise = _allExercises[index];
                final isSelected = _selectedExercises.any((e) => e.exercise.id == exercise.id);
                final routineExercise = isSelected
                    ? _selectedExercises.firstWhere((e) => e.exercise.id == exercise.id)
                    : null;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(exercise.name),
                        subtitle: Text(exercise.muscleGroup),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            _toggleExerciseSelection(exercise);
                          },
                        ),
                        onTap: () => _toggleExerciseSelection(exercise),
                      ),
                      if (isSelected && routineExercise != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            children: [
                              if (exercise.measurement == 'reps')
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: routineExercise.sets.toString(),
                                        decoration: const InputDecoration(labelText: 'Series'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            routineExercise.sets = int.tryParse(value) ?? 3;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: routineExercise.reps,
                                        decoration: const InputDecoration(labelText: 'Repeticiones'),
                                        onChanged: (value) {
                                          setState(() {
                                            routineExercise.reps = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              else if (exercise.measurement == 'time')
                                TextFormField(
                                  initialValue: routineExercise.reps, // Usaremos 'reps' para guardar el tiempo
                                  decoration: const InputDecoration(labelText: 'Tiempo (segundos)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      routineExercise.reps = value;
                                    });
                                  },
                                ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                initialValue: (routineExercise.restTime ?? 60).toString(),
                                decoration: const InputDecoration(labelText: 'Descanso (segundos)'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    routineExercise.restTime = int.tryParse(value) ?? 60;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
