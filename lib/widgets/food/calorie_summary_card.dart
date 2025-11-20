import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:myapp/screens/settings/caloric_goals_screen.dart';
import 'package:myapp/widgets/food/macro_progress_bar.dart';

class CalorieSummaryCard extends StatelessWidget {
  final double? caloriesGoal;
  final double caloriesConsumed;
  final double proteinGoal;
  final double proteinConsumed;
  final double carbsGoal;
  final double carbsConsumed;
  final double fatsGoal;
  final double fatsConsumed;

  const CalorieSummaryCard({
    super.key,
    required this.caloriesGoal,
    required this.caloriesConsumed,
    required this.proteinGoal,
    required this.proteinConsumed,
    required this.carbsGoal,
    required this.carbsConsumed,
    required this.fatsGoal,
    required this.fatsConsumed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (caloriesGoal == null || caloriesGoal! <= 0) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'No has establecido tus metas calóricas',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CaloricGoalsScreen(),
                    ),
                  );
                },
                child: const Text('Establecer Metas'),
              ),
            ],
          ),
        ),
      );
    }

    final caloriesRemaining = (caloriesGoal! - caloriesConsumed).clamp(
      0.0,
      caloriesGoal!,
    );
    final calorieProgress = caloriesGoal! > 0
        ? (caloriesConsumed / caloriesGoal!).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: CalorieRingPainter(
                      progress: calorieProgress,
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.primary.withAlpha(
                        (255 * 0.2).round(),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            caloriesConsumed.toStringAsFixed(0),
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text('Consumido', style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalorieStat(
                      'Meta',
                      caloriesGoal!,
                      textTheme,
                      colorScheme.onSurface,
                    ),
                    const SizedBox(height: 12),
                    _buildCalorieStat(
                      'Restante',
                      caloriesRemaining,
                      textTheme,
                      Colors.green.shade600,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: MacroProgressBar(
                    title: 'Proteínas',
                    consumed: proteinConsumed,
                    goal: proteinGoal,
                    color: Colors.orange.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MacroProgressBar(
                    title: 'Carbs',
                    consumed: carbsConsumed,
                    goal: carbsGoal,
                    color: Colors.lightBlue.shade500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MacroProgressBar(
                    title: 'Grasas',
                    consumed: fatsConsumed,
                    goal: fatsGoal,
                    color: Colors.purple.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieStat(
    String label,
    double value,
    TextTheme textTheme,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(
          value.toStringAsFixed(0),
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class CalorieRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  CalorieRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from the top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever the progress changes
  }
}
