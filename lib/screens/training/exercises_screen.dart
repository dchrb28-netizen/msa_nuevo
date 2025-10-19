import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/screens/training/exercise_detail_screen.dart';

class ExercisesScreen extends StatelessWidget {
  final List<Exercise> exercises;
  final VoidCallback onRefresh;

  const ExercisesScreen({super.key, required this.exercises, required this.onRefresh});

  void _navigateToDetail(BuildContext context, Exercise exercise) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );

    if (result == true) {
      onRefresh();
    }
  }

  IconData _getMuscleIcon(String muscleGroup) {
    switch (muscleGroup) {
      case 'Pecho':
        return Icons.volunteer_activism;
      case 'Espalda':
        return Icons.arrow_back_ios_new_rounded;
      case 'Piernas':
        return Icons.airline_seat_legroom_normal_rounded;
      case 'Hombros':
        return Icons.shield_rounded;
      case 'Brazos':
        return Icons.military_tech_rounded;
      case 'Abdominales':
        return Icons.accessibility_new;
      case 'Cuerpo Completo':
        return Icons.person_search_rounded;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.style, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aún no has creado ningún ejercicio',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Ve a la pestaña de Biblioteca y pulsa el botón + para añadir tu primer ejercicio.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _getMuscleIcon(exercise.muscleGroup),
                size: 28,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${exercise.type} - ${exercise.equipment}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _navigateToDetail(context, exercise),
          ),
        );
      },
    );
  }
}
