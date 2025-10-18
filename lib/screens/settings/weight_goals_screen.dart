import 'package:flutter/material.dart';

class WeightGoalsScreen extends StatelessWidget {
  const WeightGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetivos de Peso'),
      ),
      body: const Center(
        child: Text('Pantalla de Objetivos de Peso'),
      ),
    );
  }
}
