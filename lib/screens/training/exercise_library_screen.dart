import 'package:flutter/material.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Ejercicios'),
      ),
      body: const Center(
        child: Text('Pantalla de Biblioteca de Ejercicios'),
      ),
    );
  }
}
