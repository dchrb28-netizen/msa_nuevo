import 'package:flutter/material.dart';
import 'package:myapp/screens/training/routines_screen.dart';
import 'package:myapp/widgets/ui/watermark_image.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        WatermarkImage(imageName: 'entrenamiento'),
        RoutinesScreen(),
      ],
    );
  }
}
