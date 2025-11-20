import 'package:flutter/material.dart';

class MacroProgressBar extends StatelessWidget {
  final String title;
  final double consumed;
  final double goal;
  final Color color;

  const MacroProgressBar({
    super.key,
    required this.title,
    required this.consumed,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${consumed.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} g',
              style: textTheme.bodySmall,
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withAlpha((255 * 0.2).round()), // CORREGIDO
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
