import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/screens/training/exercise_detail_screen.dart';
import 'package:myapp/widgets/empty_state_widget.dart';

class ExercisesScreen extends StatelessWidget {
  final List<Exercise> exercises;
  final VoidCallback onRefresh;

  const ExercisesScreen({
    super.key,
    required this.exercises,
    required this.onRefresh,
  });

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

  IconData _getMuscleIcon(String? muscleGroup) {
    switch (muscleGroup?.toLowerCase()) {
      case 'pecho':
        return Icons.volunteer_activism;
      case 'espalda':
        return Icons.arrow_back_ios_new_rounded;
      case 'piernas':
        return Icons.airline_seat_legroom_normal_rounded;
      case 'hombros':
        return Icons.shield_rounded;
      case 'brazos':
        return Icons.military_tech_rounded;
      case 'abdominales':
        return Icons.accessibility_new;
      case 'cuerpo completo':
        return Icons.person_search_rounded;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.style,
        title: 'Aún no has creado ningún ejercicio',
        subtitle: 'Ve a la pestaña de Biblioteca y pulsa el botón + para añadir tu primer ejercicio.',
        iconColor: Colors.red[400],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _getMuscleIcon(exercise.muscleGroup),
                size: 28,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              exercise.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${exercise.type ?? 'N/A'} - ${exercise.equipment ?? 'N/A'}',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _navigateToDetail(context, exercise),
          ),
        );
      },
    );
  }
}
