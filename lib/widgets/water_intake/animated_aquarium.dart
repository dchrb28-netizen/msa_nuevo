import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;
import 'package:flutter/services.dart';
import 'package:simple_animations/simple_animations.dart';

class AnimatedAquarium extends StatefulWidget {
  final int totalWater;
  final int dailyGoal;

  const AnimatedAquarium({
    super.key,
    required this.totalWater,
    required this.dailyGoal,
  });

  @override
  State<AnimatedAquarium> createState() => _AnimatedAquariumState();
}

class _AnimatedAquariumState extends State<AnimatedAquarium> {
  Artboard? _riveArtboard;
  SMIInput<double>? _waterLevelInput;
  Artboard? _bubblesArtboard;

  @override
  void initState() {
    super.initState();
    _loadRiveFile('assets/rive/aquarium.riv', (artboard) {
      var controller = StateMachineController.fromArtboard(
        artboard,
        'State Machine 1',
      );
      if (controller != null) {
        artboard.addController(controller);
        _waterLevelInput = controller.findInput<double>('waterLevel');
        setState(() => _riveArtboard = artboard);
        _updateWaterLevel();
      }
    });
    _loadRiveFile('assets/rive/bubbles.riv', (artboard) {
      artboard.addController(SimpleAnimation('go'));
      setState(() => _bubblesArtboard = artboard);
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedAquarium oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.totalWater != oldWidget.totalWater) {
      _updateWaterLevel();
    }
  }

  void _loadRiveFile(String path, Function(Artboard) onLoaded) {
    rootBundle.load(path).then((data) async {
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      onLoaded(artboard);
    });
  }

  void _updateWaterLevel() {
    if (_waterLevelInput != null) {
      double fillPercentage = (widget.totalWater / widget.dailyGoal).clamp(
        0.0,
        1.0,
      );
      _waterLevelInput!.value = fillPercentage * 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double fillPercentage = (widget.totalWater / widget.dailyGoal).clamp(
      0.0,
      1.0,
    );
    bool goalReached = widget.totalWater >= widget.dailyGoal;

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withAlpha(204),
            colorScheme.primary.withAlpha(102),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          if (_riveArtboard != null)
            Rive(artboard: _riveArtboard!, fit: BoxFit.cover),
          if (_bubblesArtboard != null && fillPercentage > 0.1)
            Opacity(
              opacity: min(1, fillPercentage * 2),
              child: Rive(artboard: _bubblesArtboard!, fit: BoxFit.cover),
            ),
          ..._buildMarineLife(fillPercentage),
          if (goalReached) _buildConfetti(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.totalWater} ml',
                  style: GoogleFonts.montserrat(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withAlpha(128),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Meta: ${widget.dailyGoal} ml',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white.withAlpha(230),
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black.withAlpha(128),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMarineLife(double progress) {
    final animals = [
      {
        'path': 'assets/images/fish1.png',
        'start': 0.1,
        'end': 0.8,
        'size': 40.0,
        'alignment': const Alignment(-0.8, 0.7),
      },
      {
        'path': 'assets/images/fish2.png',
        'start': 0.2,
        'end': 0.9,
        'size': 50.0,
        'alignment': const Alignment(0.7, 0.4),
      },
      {
        'path': 'assets/images/fish3.png',
        'start': 0.3,
        'end': 1.0,
        'size': 45.0,
        'alignment': const Alignment(0.2, -0.3),
      },
      {
        'path': 'assets/images/fish4.png',
        'start': 0.4,
        'end': 1.0,
        'size': 55.0,
        'alignment': const Alignment(-0.5, -0.6),
      },
      {
        'path': 'assets/images/fish5.png',
        'start': 0.8,
        'end': 1.0,
        'size': 60.0,
        'alignment': const Alignment(0.9, 0.9),
      },

      {
        'path': 'assets/images/jellyfish1.png',
        'start': 0.25,
        'end': 0.9,
        'size': 50.0,
        'alignment': const Alignment(0.9, -0.8),
      },
      {
        'path': 'assets/images/jellyfish2.png',
        'start': 0.6,
        'end': 1.0,
        'size': 55.0,
        'alignment': const Alignment(-0.9, -0.2),
      },

      {
        'path': 'assets/images/turtle1.png',
        'start': 0.5,
        'end': 1.0,
        'size': 70.0,
        'alignment': const Alignment(0.1, 0.1),
      },
      {
        'path': 'assets/images/turtle2.png',
        'start': 0.7,
        'end': 1.0,
        'size': 65.0,
        'alignment': const Alignment(-0.2, 0.5),
      },

      {
        'path': 'assets/images/dolphin1.png',
        'start': 0.65,
        'end': 1.0,
        'size': 80.0,
        'alignment': const Alignment(-0.9, 0.3),
      },
      {
        'path': 'assets/images/dolphin2.png',
        'start': 0.85,
        'end': 1.0,
        'size': 75.0,
        'alignment': const Alignment(0.8, -0.1),
      },

      {
        'path': 'assets/images/starfish1.png',
        'start': 0.1,
        'end': 1.0,
        'size': 30.0,
        'alignment': const Alignment(0.5, 0.9),
      },
      {
        'path': 'assets/images/starfish2.png',
        'start': 0.3,
        'end': 1.0,
        'size': 35.0,
        'alignment': const Alignment(-0.4, 0.2),
      },
      {
        'path': 'assets/images/starfish3.png',
        'start': 0.5,
        'end': 1.0,
        'size': 32.0,
        'alignment': const Alignment(0.9, 0.1),
      },
    ];

    return animals.map((animal) {
      final showAt = animal['start'] as double;
      final moveUntil = animal['end'] as double;
      final isVisible = progress > showAt;
      final moveProgress = ((progress - showAt) / (moveUntil - showAt)).clamp(
        0.0,
        1.0,
      );

      return Positioned.fill(
        child: Align(
          alignment: animal['alignment'] as Alignment,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isVisible ? 1.0 : 0.0,
            child: Transform.translate(
              offset: Offset(
                0,
                (1 - moveProgress) * 50,
              ), // Move up as progress increases
              child: Image.asset(
                animal['path'] as String,
                width: animal['size'] as double,
                errorBuilder: (c, o, s) => const SizedBox(),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildConfetti() {
    final Random random = Random();
    return Stack(
      children: List.generate(50, (index) {
        final size = random.nextDouble() * 10 + 5;
        final Alignment alignment = Alignment(
          random.nextDouble() * 2 - 1,
          random.nextDouble() * 2 - 1,
        );
        final Color color =
            Colors.primaries[random.nextInt(Colors.primaries.length)];

        return Positioned.fill(
          child: Align(
            alignment: alignment,
            child: LoopAnimationBuilder(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 1500 + random.nextInt(1500)),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value * 200 - 100), // Fall down
                  child: Transform.rotate(
                    angle: value * 2 * pi, // Rotate
                    child: child,
                  ),
                );
              },
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        );
      }),
    );
  }
}
