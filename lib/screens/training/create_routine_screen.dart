import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/services/exercise_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _allExercises = [];
  final List<Exercise> _selectedExercises = [];
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
      if (_selectedExercises.contains(exercise)) {
        _selectedExercises.remove(exercise);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  void _saveRoutine() {
    // Aquí guardaremos la rutina seleccionada
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
                final isSelected = _selectedExercises.contains(exercise);
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(exercise.muscleGroup),
                  trailing: Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                  onTap: () => _toggleExerciseSelection(exercise),
                );
              },
            ),
    );
  }
}
