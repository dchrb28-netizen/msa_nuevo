import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myapp/widgets/dashboard/bubble_painter.dart';
import 'package:simple_animations/simple_animations.dart';

class Bubble extends StatelessWidget {
  final double size;
  final double initialX;

  const Bubble({super.key, required this.size, required this.initialX});

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1500 + Random().nextInt(1500)),
      delay: Duration(milliseconds: Random().nextInt(2000)),
      builder: (context, value, child) {
        return Positioned(
          left: initialX + (sin(value * 2 * pi) * 20),
          bottom: (value * 500) - 50,
          child: Opacity(
            opacity: 1.0 - value,
            child: CustomPaint(
              painter: BubblePainter(),
              size: Size(size, size),
            ),
          ),
        );
      },
    );
  }
}
