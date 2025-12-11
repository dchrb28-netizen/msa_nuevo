import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeightProgressCard extends StatelessWidget {
  final double? lastWeight;
  final double weightGoal;

  const WeightProgressCard({
    super.key,
    required this.lastWeight,
    required this.weightGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (lastWeight == null || lastWeight! <= 0) {
      // State when goal is set but no weight is logged yet
      return _buildInitialState(theme);
    } else {
      // State when goal is set and weight is logged
      return _buildProgressState(theme);
    }
  }

  Widget _buildInitialState(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Tu Meta de Peso',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Icon(Icons.flag_outlined, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 12),
            Text(
              '${weightGoal.toStringAsFixed(1)} kg',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '¡Registra tu peso para comenzar a ver tu progreso!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressState(ThemeData theme) {
    final initialWeight =
        weightGoal + 15; // Placeholder for a more realistic initial weight
    final weightDifference = lastWeight! - weightGoal;
    // Progress calculation: 0.0 means at initial weight, 1.0 means goal is reached.
    final progress =
        1.0 - (weightDifference.abs() / (initialWeight - weightGoal).abs());
    final cappedProgress = math.max(0.0, math.min(1.0, progress));

    final bool isLosingWeight = initialWeight > weightGoal;
    final Color progressColor =
        (isLosingWeight && lastWeight! <= weightGoal) ||
            (!isLosingWeight && lastWeight! >= weightGoal)
        ? Colors.green.shade500
        : Colors.blueAccent;
    final String message = weightDifference == 0
        ? '¡Felicidades! Has alcanzado tu meta.'
        : '${weightDifference.abs().toStringAsFixed(1)} kg para tu meta';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Tu Progreso',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildWeightInfo(
                    'Peso Actual',
                    lastWeight!.toStringAsFixed(1),
                    theme,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildWeightInfo(
                    'Meta',
                    weightGoal.toStringAsFixed(1),
                    theme,
                    isGoal: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: cappedProgress,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  weightDifference <= 0
                      ? Icons.check_circle_outline
                      : Icons.trending_down,
                  color: weightDifference <= 0
                      ? Colors.green.shade600
                      : Colors.red.shade400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: weightDifference <= 0
                        ? Colors.green.shade600
                        : Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInfo(
    String label,
    String value,
    ThemeData theme, {
    bool isGoal = false,
  }) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoal)
              const Icon(
                Icons.flag_outlined,
                color: Colors.blueAccent,
                size: 28,
              ),
            if (!isGoal)
              Icon(
                Icons.monitor_weight_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            const SizedBox(width: 8),
            Text(
              '$value kg',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isGoal ? Colors.blueAccent : theme.colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
