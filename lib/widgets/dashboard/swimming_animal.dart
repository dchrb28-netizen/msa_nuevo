import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class SwimmingAnimal extends StatelessWidget {
  final String imagePath;
  final double size;
  final Duration duration;
  final bool flip;

  const SwimmingAnimal({
    super.key,
    required this.imagePath,
    required this.size,
    required this.duration,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return LoopAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        final x = -value * 200 + 100;
        final y = sin(value * pi * 2) * 20 + 50;

        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scaleX: flip ? -1.0 : 1.0,
            child: Image.asset(
              imagePath,
              width: size,
              height: size,
            ),
          ),
        );
      },
    );
  }
}
