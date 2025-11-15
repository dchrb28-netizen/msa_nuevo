import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  exercise.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    const Center(child: Icon(Icons.image_not_supported, size: 100)),
                ),
              ),
            const SizedBox(height: 24),

            Text(
              exercise.name,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              exercise.description,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            _buildInfoCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(theme, Icons.fitness_center, 'Grupo Muscular', exercise.muscleGroup),
            const Divider(height: 24),
            _buildInfoRow(theme, Icons.construction, 'Equipamiento', exercise.equipment),
            const Divider(height: 24),
            _buildInfoRow(theme, Icons.category, 'Tipo', exercise.type),
            const Divider(height: 24),
             _buildInfoRow(theme, Icons.repeat, 'Medición', exercise.measurement == 'reps' ? 'Repeticiones' : 'Tiempo'),
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
            Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
