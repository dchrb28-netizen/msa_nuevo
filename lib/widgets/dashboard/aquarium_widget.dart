import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myapp/widgets/dashboard/bubble.dart';
import 'package:myapp/widgets/dashboard/swimming_animal.dart';
import 'package:myapp/widgets/dashboard/wave_bubble.dart';
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
    for (int i = 0; i < 30; i++) {
      bubbles.add(
        Bubble(
          size: 10 + Random().nextDouble() * 20,
          initialX: Random().nextDouble() * 400,
        ),
      );
    }

    animals.addAll([
      SwimmingAnimal(
        imagePath: 'assets/acuario/dolphin1.png',
        size: 100,
        duration: const Duration(seconds: 25),
        initialY: 20,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/turtle1.png',
        size: 80,
        duration: const Duration(seconds: 30),
        initialY: 120,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/fish1.png',
        size: 40,
        duration: const Duration(seconds: 12),
        initialY: 60,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/fish2.png',
        size: 50,
        duration: const Duration(seconds: 15),
        initialY: 180,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/jellyfish1.png',
        size: 45,
        duration: const Duration(seconds: 20),
        initialY: 90,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/starfish1.png',
        size: 35,
        duration: const Duration(seconds: 35),
        initialY: 220,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/dolphin2.png',
        size: 120,
        duration: const Duration(seconds: 28),
        initialY: 40,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/turtle2.png',
        size: 90,
        duration: const Duration(seconds: 32),
        initialY: 140,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/fish3.png',
        size: 45,
        duration: const Duration(seconds: 14),
        initialY: 80,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/fish4.png',
        size: 55,
        duration: const Duration(seconds: 17),
        initialY: 200,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/jellyfish2.png',
        size: 50,
        duration: const Duration(seconds: 22),
        initialY: 110,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/starfish2.png',
        size: 40,
        duration: const Duration(seconds: 38),
        initialY: 240,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/fish5.png',
        size: 60,
        duration: const Duration(seconds: 18),
        initialY: 160,
        flip: Random().nextBool(),
      ),
      SwimmingAnimal(
        imagePath: 'assets/acuario/starfish3.png',
        size: 70,
        duration: const Duration(seconds: 26),
        initialY: 260,
        flip: Random().nextBool(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final waterPercentage = (widget.totalWater / widget.dailyGoal).clamp(
      0.0,
      1.0,
    );

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/acuario/oceano.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          ...animals,
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
          ...bubbles,
          WaveBubbleGenerator(waterPercentage: waterPercentage),
          const MarineMist(),
        ],
      ),
    );
  }
}

class MarineMist extends StatelessWidget {
  const MarineMist({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withAlpha(102), // 0.4 opacity
              Colors.white.withAlpha(26), // 0.1 opacity
              Colors.transparent,
            ],
            stops: const [0.0, 0.2, 0.5],
          ),
        ),
      ),
    );
  }
}

class WaveBubbleGenerator extends StatefulWidget {
  final double waterPercentage;

  const WaveBubbleGenerator({super.key, required this.waterPercentage});

  @override
  State<WaveBubbleGenerator> createState() => _WaveBubbleGeneratorState();
}

class _WaveBubbleGeneratorState extends State<WaveBubbleGenerator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Widget> waveBubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (Random().nextDouble() < 0.2) {
          final x = Random().nextDouble() * 400;
          final y = (1 - widget.waterPercentage) * 500 + sin(x * 0.02) * 20;
          waveBubbles.add(WaveBubble(initialX: x, initialY: y));
        }

        if (waveBubbles.length > 20) {
          waveBubbles.removeAt(0);
        }

        return Stack(children: waveBubbles);
      },
    );
  }
}
