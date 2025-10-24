import 'package:flutter/material.dart';
import 'package:myapp/widgets/ui/watermark_image.dart';

class ProgresoScreen extends StatelessWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        WatermarkImage(imageName: 'progreso'),
        Center(
          child: Text('Pantalla de Progreso'),
        ),
      ],
    );
  }
}
