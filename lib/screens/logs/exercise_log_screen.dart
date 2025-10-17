import 'package:flutter/material.dart';
import 'package:myapp/widgets/ui/screen_background.dart';

class ExerciseLogScreen extends StatelessWidget {
  const ExerciseLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Ejercicio'),
      ),
      body: Stack(
        children: [
          const ScreenBackground(screenName: 'entrenamiento'),
          const Center(
            child: Text('Aquí podrás registrar tus ejercicios.'),
          ),
        ],
      ),
    );
  }
}
