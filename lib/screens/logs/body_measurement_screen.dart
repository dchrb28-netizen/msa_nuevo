import 'package:flutter/material.dart';
import 'package:myapp/widgets/ui/screen_background.dart';

class BodyMeasurementScreen extends StatelessWidget {
  const BodyMeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medición Corporal'),
      ),
      body: Stack(
        children: [
          const ScreenBackground(screenName: 'medida'),
          const Center(
            child: Text('Aquí podrás registrar tus mediciones corporales.'),
          ),
        ],
      ),
    );
  }
}
