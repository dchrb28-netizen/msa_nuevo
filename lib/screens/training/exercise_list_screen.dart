import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/screens/training/add_exercise_screen.dart';
import 'package:myapp/screens/training/edit_exercise_screen.dart';
import 'package:myapp/services/exercise_service.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  late Future<List<Exercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() {
      _exercisesFuture = _exerciseService.loadExercises();
    });
  }

  void _navigateToAddExercise() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
    );

    if (result == true) {
      _loadExercises();
    }
  }

  void _navigateToEditExercise(Exercise exercise) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExerciseScreen(exercise: exercise),
      ),
    );

    if (result != null) {
      _loadExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No has creado ningún ejercicio.'));
          }
          final exercises = snapshot.data!;
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ListTile(
                title: Text(exercise.name),
                subtitle: Text(exercise.muscleGroup),
                onTap: () => _navigateToEditExercise(exercise),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExercise,
        tooltip: 'Añadir Ejercicio',
        child: const Icon(Icons.add),
      ),
    );
  }
}
