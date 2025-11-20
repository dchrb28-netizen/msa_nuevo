import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determina si hay alguna recomendación general que mostrar.
    final bool hasGeneralRecommendations =
        exercise.recommendations != null &&
        exercise.recommendations!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(exercise.name), centerTitle: true),
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
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.image_not_supported, size: 100),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            Text(
              exercise.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              exercise.description ?? 'No hay descripción disponible.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            _buildInfoCard(theme),
            const SizedBox(height: 24),

            _buildRecommendationsCard(theme),
            const SizedBox(height: 24),

            // Solo muestra la tarjeta si hay recomendaciones generales.
            if (hasGeneralRecommendations)
              _buildGeneralRecommendationsCard(theme),
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
            _buildInfoRow(
              theme,
              Icons.fitness_center,
              'Grupo Muscular',
              exercise.muscleGroup ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              theme,
              Icons.construction,
              'Equipamiento',
              exercise.equipment ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              theme,
              Icons.leaderboard,
              'Dificultad',
              exercise.difficulty ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              theme,
              Icons.repeat,
              'Medición',
              (exercise.measurement ?? 'reps') == 'reps'
                  ? 'Repeticiones'
                  : 'Tiempo',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recomendaciones por Nivel',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationRow(
              theme,
              'Principiante',
              exercise.beginnerSets ?? 'N/A',
              exercise.beginnerReps ?? 'N/A',
              exercise.measurement ?? 'reps',
            ),
            const Divider(height: 16),
            _buildRecommendationRow(
              theme,
              'Intermedio',
              exercise.intermediateSets ?? 'N/A',
              exercise.intermediateReps ?? 'N/A',
              exercise.measurement ?? 'reps',
            ),
            const Divider(height: 16),
            _buildRecommendationRow(
              theme,
              'Avanzado',
              exercise.advancedSets ?? 'N/A',
              exercise.advancedReps ?? 'N/A',
              exercise.measurement ?? 'reps',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralRecommendationsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recomendaciones Generales',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(exercise.recommendations!, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationRow(
    ThemeData theme,
    String level,
    String sets,
    String reps,
    String measurement,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          level,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (sets != 'N/A')
              Text('Series: $sets', style: theme.textTheme.bodyLarge),
            Text(
              '${measurement == 'reps' ? 'Reps' : 'Duración'}: $reps',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
