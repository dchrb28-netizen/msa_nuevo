import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:myapp/screens/training/edit_exercise_screen.dart';
import 'package:provider/provider.dart';

class ExerciseListScreen extends StatelessWidget {
  const ExerciseListScreen({super.key});

  void _navigateToAddExercise(BuildContext context) async {
    final newExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(builder: (context) => const EditExerciseScreen()),
    );

    if (newExercise != null && context.mounted) {
      Provider.of<ExerciseProvider>(
        context,
        listen: false,
      ).addExercise(newExercise);
    }
  }

  void _navigateToEditExercise(BuildContext context, Exercise exercise) async {
    final updatedExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => EditExerciseScreen(exercise: exercise),
      ),
    );

    if (updatedExercise != null && context.mounted) {
      Provider.of<ExerciseProvider>(
        context,
        listen: false,
      ).updateExercise(updatedExercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExerciseProvider>(
        builder: (context, exerciseProvider, child) {
          final exercises = exerciseProvider.exercises;
          if (exercises.isEmpty) {
            return const Center(child: Text('No has creado ningún ejercicio.'));
          }
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ListTile(
                title: Text(exercise.name),
                subtitle: Text(exercise.muscleGroup ?? 'Sin grupo muscular'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    // Opcional: Añadir un diálogo de confirmación aquí
                    exerciseProvider.deleteExercise(exercise.id);
                  },
                ),
                onTap: () => _navigateToEditExercise(context, exercise),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExercise(context),
        tooltip: 'Añadir Ejercicio',
        child: const Icon(Icons.add),
      ),
    );
  }
}
