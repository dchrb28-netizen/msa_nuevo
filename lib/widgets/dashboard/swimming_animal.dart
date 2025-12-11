import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class SwimmingAnimal extends StatelessWidget {
  final String imagePath;
  final double size;
  final Duration duration;
  final bool flip;
  final double initialY;

  const SwimmingAnimal({
    super.key,
    required this.imagePath,
    required this.size,
    required this.duration,
    this.flip = false,
    this.initialY = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..scene(begin: const Duration(milliseconds: 0), end: duration).tween(
        'x',
        Tween<double>(begin: -size, end: 400.0),
        curve: Curves.easeInOutSine,
      )
      ..scene(begin: const Duration(milliseconds: 0), end: duration).tween(
        'y',
        Tween<double>(
          begin: initialY,
          end: initialY + Random().nextDouble() * 100 - 50,
        ),
        curve: Curves.easeInOutSine,
      )
      ..scene(
        begin: const Duration(milliseconds: 0),
        end: duration,
      ).tween('progress', Tween<double>(begin: 0.0, end: 1.0));

    return LoopAnimationBuilder<Movie>(
      tween: tween,
      duration: tween.duration,
      builder: (context, value, child) {
        final x = value.get('x');
        final y = value.get('y');
        final angle = sin(value.get('progress') * pi * 4) * 0.1;

        return Positioned(
          left: flip ? 400.0 - x - size : x,
          top: y,
          child: Transform.scale(
            scaleX: flip ? -1.0 : 1.0,
            child: Transform.rotate(
              angle: angle,
              child: Image.asset(
                imagePath,
                width: size,
                height: size,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
        );
      },
    );
  }
}
