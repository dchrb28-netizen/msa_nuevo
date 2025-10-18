import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/screens/training/exercise_detail_screen.dart';
import 'package:myapp/services/exercise_service.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => ExerciseLibraryScreenState();
}

class ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  Future<void> loadExercises() async {
    if (!mounted) return;
    final exercises = await _exerciseService.loadExercises();
    if (mounted) {
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    }
  }

  // Helper function to get an icon for the muscle group
  IconData _getIconForMuscleGroup(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'pecho':
        return Icons.accessibility_new_rounded;
      case 'espalda':
        return Icons.height_rounded; // Represents spine
      case 'piernas':
        return Icons.directions_walk_rounded;
      case 'hombros':
        return Icons.sports_mma_rounded;
      case 'brazos':
        return Icons.sports_handball_rounded;
      case 'abdominales':
        return Icons.fitness_center_rounded;
      case 'cardio':
        return Icons.monitor_heart_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withAlpha(240), // Slightly off-white
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
              ? Center(
                  child: Text(
                    'Tu biblioteca de ejercicios está vacía.\n¡Añade uno para empezar!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          child: Icon(_getIconForMuscleGroup(exercise.muscleGroup)),
                        ),
                        title: Text(exercise.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text(exercise.muscleGroup, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 28),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseDetailScreen(exercise: exercise),
                            ),
                          );
                          if (result == true && mounted) {
                            loadExercises();
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
