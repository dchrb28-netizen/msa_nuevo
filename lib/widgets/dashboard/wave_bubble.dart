
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:myapp/widgets/dashboard/bubble_painter.dart';

class WaveBubble extends StatelessWidget {
  final double initialX;
  final double initialY;

  const WaveBubble({
    super.key,
    required this.initialX,
    required this.initialY,
  });

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + Random().nextInt(500)),
      builder: (context, value, child) {
        return Positioned(
          left: initialX + (sin(value * pi * 2) * 5),
          top: initialY - (value * 30),
          child: Opacity(
            opacity: 1.0 - value,
            child: CustomPaint(
              painter: BubblePainter(),
              size: Size(5 + Random().nextDouble() * 5, 5 + Random().nextDouble() * 5),
            ),
          ),
        );
      },
    );
  }
}
