import 'dart:math' as math;
import 'package:flutter/material.dart';

class SunMoonTimer extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool isFasting;
  final String timeText;
  final String phaseText;
  final String goalText;
  final VoidCallback onButtonPressed;

  const SunMoonTimer({
    super.key,
    required this.progress,
    required this.isFasting,
    required this.timeText,
    required this.phaseText,
    required this.goalText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double size = 280.0;
    const double iconSize = 30.0;

    // Angle for the icon on the arc
    final angle = (math.pi * progress) - (math.pi / 2);

    final x = (size / 2) + (size / 2 - iconSize / 2) * math.cos(angle);
    final y = (size / 2) + (size / 2 - iconSize / 2) * math.sin(angle);

    final icon = isFasting ? Icons.nightlight_round : Icons.wb_sunny;
    final iconColor = isFasting ? Colors.yellow.shade200 : Colors.orange;

    final skyGradient = isFasting
        ? const LinearGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFF81C7F5), Color(0xFF3C9BED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: skyGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(size, size),
            painter: _ArcPainter(progress: progress, isFasting: isFasting),
          ),
          Positioned(
            left: x - iconSize / 2,
            top: y - iconSize / 2,
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeText,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  phaseText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  goalText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onButtonPressed,
                  icon: Icon(
                    isFasting ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 24,
                  ),
                  label: Text(
                    isFasting ? 'Parar Ayuno' : 'Empezar Ayuno',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFasting ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final bool isFasting;

  _ArcPainter({required this.progress, required this.isFasting});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withAlpha(77);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = isFasting ? Colors.blue.shade200 : Colors.yellow.shade700;

    // Draw the background track arc
    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);

    // Draw the progress arc
    canvas.drawArc(rect, math.pi, math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isFasting != isFasting;
  }
}
