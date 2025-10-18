import 'package:flutter/material.dart';

class CaloricGoalsScreen extends StatelessWidget {
  const CaloricGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas Calóricas'),
      ),
      body: const Center(
        child: Text('Pantalla de Metas Calóricas'),
      ),
    );
  }
}
