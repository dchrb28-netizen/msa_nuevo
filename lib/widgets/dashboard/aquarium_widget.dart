import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myapp/widgets/dashboard/bubble.dart';
import 'package:myapp/widgets/dashboard/swimming_animal.dart';
import 'package:myapp/widgets/dashboard/wave_painter.dart';
import 'package:simple_animations/simple_animations.dart';

class AquariumWidget extends StatefulWidget {
  final double totalWater;
  final double dailyGoal;

  const AquariumWidget({
    super.key,
    required this.totalWater,
    required this.dailyGoal,
  });

  @override
  State<AquariumWidget> createState() => _AquariumWidgetState();
}

class _AquariumWidgetState extends State<AquariumWidget> {
  final List<Bubble> bubbles = [];
  final List<SwimmingAnimal> animals = [];

  @override
  void initState() {
    super.initState();
    // Generate a set of bubbles
    for (int i = 0; i < 30; i++) {
      bubbles.add(Bubble(
        size: 10 + Random().nextDouble() * 20,
        initialX: Random().nextDouble() * 400,
      ));
    }

    // Add swimming animals
    animals.addAll([
      const SwimmingAnimal(imagePath: 'assets/images/fish1.png', size: 50, duration: Duration(seconds: 10)),
      const SwimmingAnimal(imagePath: 'assets/images/fish2.png', size: 60, duration: Duration(seconds: 15), flip: true),
      const SwimmingAnimal(imagePath: 'assets/images/fish3.png', size: 40, duration: Duration(seconds: 8)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final waterPercentage = (widget.totalWater / widget.dailyGoal).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade200,
            Colors.blue.shade800,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Wave animation
          LoopAnimationBuilder(
            tween: Tween(begin: 0.0, end: 2 * pi),
            duration: const Duration(seconds: 4),
            builder: (context, value, child) {
              return CustomPaint(
                painter: WavePainter(
                  waterHeight: waterPercentage,
                  wavePhase: value,
                ),
                size: Size.infinite,
              );
            },
          ),
          // Bubbles
          ...bubbles,
          // Animals
          ...animals,
        ],
      ),
    );
  }
}
