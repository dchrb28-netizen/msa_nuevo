import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:flutter/services.dart';

class AnimatedAquarium extends StatefulWidget {
  final int totalWater;
  final int dailyGoal;

  const AnimatedAquarium({super.key, required this.totalWater, required this.dailyGoal});

  @override
  State<AnimatedAquarium> createState() => _AnimatedAquariumState();
}

class _AnimatedAquariumState extends State<AnimatedAquarium> {
  Artboard? _riveArtboard;
  SMIInput<double>? _waterLevelInput;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  @override
  void didUpdateWidget(covariant AnimatedAquarium oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.totalWater != oldWidget.totalWater) {
      _updateWaterLevel();
    }
  }

  void _loadRiveFile() {
    rootBundle.load('assets/rive/aquarium.riv').then(
      (data) async {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        var controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
        if (controller != null) {
          artboard.addController(controller);
          _waterLevelInput = controller.findInput<double>('waterLevel');
          setState(() => _riveArtboard = artboard);
          _updateWaterLevel();
        }
      },
    );
  }

  void _updateWaterLevel() {
    if (_waterLevelInput != null) {
      double fillPercentage = (widget.totalWater / widget.dailyGoal).clamp(0.0, 1.0);
      _waterLevelInput!.value = fillPercentage * 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                    shadows: [Shadow(blurRadius: 10.0, color: Colors.black.withAlpha(128))],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Meta: ${widget.dailyGoal} ml',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white.withAlpha(230),
                    shadows: [Shadow(blurRadius: 5.0, color: Colors.black.withAlpha(128))],
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
