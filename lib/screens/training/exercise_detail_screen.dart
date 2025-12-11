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
      appBar: AppBar(centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GIF demostrativo del ejercicio
            if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Stack(
                    children: [
                      exercise.imageUrl!.startsWith('http')
                          ? Image.network(
                              exercise.imageUrl!,
                              height: 280,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 280,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 280,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('Demostración no disponible', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Image.asset(
                              exercise.imageUrl!,
                              height: 280,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 280,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('Demostración no disponible', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      // Badge indicando que es una demostración
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_outline, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Demostración',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
