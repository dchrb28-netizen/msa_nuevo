import 'dart:math';
import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double waterHeight;
  final double wavePhase;

  WavePainter({required this.waterHeight, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromRGBO(68, 138, 255, 0.5),
          const Color.fromRGBO(30, 136, 229, 0.5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveHeight = 20 + 20 * waterHeight;
    final waveFrequency = 0.02;
    final waveSpeed = 1.5;

    path.moveTo(0, size.height);
    path.lineTo(0, size.height * (1 - waterHeight));

    for (double i = 0; i < size.width; i++) {
      path.lineTo(
        i,
        size.height * (1 - waterHeight) +
            sin((i * waveFrequency) + (wavePhase * waveSpeed)) * waveHeight,
      );
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
