import 'dart:math';
import 'package:flutter/material.dart';

class WaveWidget extends StatefulWidget {
  final double waterLevel;

  const WaveWidget({super.key, required this.waterLevel});

  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with TickerProviderStateMixin {
  late AnimationController _firstController;
  late AnimationController _secondController;
  late Animation<double> _firstAnimation;
  late Animation<double> _secondAnimation;

  @override
  void initState() {
    super.initState();
    _firstController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _firstAnimation = Tween(begin: 0.0, end: 2 * pi).animate(_firstController);

    _secondController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7), // Different duration for a different speed
    )..repeat();
    _secondAnimation = Tween(begin: 0.0, end: 2 * pi).animate(_secondController);
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_firstAnimation, _secondAnimation]),
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            waterLevel: widget.waterLevel,
            firstWaveOffset: _firstAnimation.value,
            secondWaveOffset: _secondAnimation.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double waterLevel;
  final double firstWaveOffset;
  final double secondWaveOffset;

  WavePainter({
    required this.waterLevel,
    required this.firstWaveOffset,
    required this.secondWaveOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the first wave
    final paint1 = Paint()
      ..color = Colors.blue.withAlpha(153) // 0.6 opacity
      ..style = PaintingStyle.fill;

    // Paint for the second wave
    final paint2 = Paint()
      ..color = Colors.blue.withAlpha(102) // 0.4 opacity
      ..style = PaintingStyle.fill;

    _drawWave(canvas, size, paint1, firstWaveOffset, 15.0, 1.0);
    _drawWave(canvas, size, paint2, secondWaveOffset, 20.0, 1.5);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double offset, double waveHeight, double waveFrequency) {
    final path = Path();
    final y = size.height * (1 - waterLevel);
    path.moveTo(0, y);

    for (double x = 0; x <= size.width; x++) {
      final wave = sin((x * waveFrequency * 2 * pi / size.width) + offset);
      path.lineTo(x, y + wave * waveHeight);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.waterLevel != waterLevel ||
        oldDelegate.firstWaveOffset != firstWaveOffset ||
        oldDelegate.secondWaveOffset != secondWaveOffset;
  }
}
