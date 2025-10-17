import 'package:flutter/material.dart';

class ObjectivesScreen extends StatelessWidget {
  const ObjectivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetivos'),
      ),
      body: const Center(
        child: Text('Pantalla de Objetivos'),
      ),
    );
  }
}
