import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/screens/training/edit_exercise_screen.dart';
import 'package:myapp/services/exercise_service.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final ExerciseService _exerciseService = ExerciseService();

  ExerciseDetailScreen({super.key, required this.exercise});

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditExerciseScreen(exercise: exercise)),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true); // Return to library and signal a refresh
    }
  }

  void _deleteExercise(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar "${exercise.name}"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final exercises = await _exerciseService.loadExercises();
      exercises.removeWhere((e) => e.id == exercise.id);
      await _exerciseService.saveExercises(exercises);
      Navigator.of(context).pop(true); // Return to library and signal a refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(onPressed: () => _navigateToEdit(context), icon: const Icon(Icons.edit_rounded), tooltip: 'Editar'),
          IconButton(onPressed: () => _deleteExercise(context), icon: const Icon(Icons.delete_outline_rounded), tooltip: 'Eliminar'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(theme),
            const SizedBox(height: 24),
            _buildSectionTitle(theme, 'Descripción'),
            const SizedBox(height: 8),
            Text(
              exercise.description.isNotEmpty ? exercise.description : 'No hay descripción disponible.',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(theme, Icons.fitness_center_rounded, 'Tipo', exercise.type),
            const Divider(height: 24),
            _buildInfoRow(theme, Icons.category_rounded, 'Grupo Muscular', exercise.muscleGroup),
            const Divider(height: 24),
            _buildInfoRow(theme, Icons.build_rounded, 'Equipamiento', exercise.equipment),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
