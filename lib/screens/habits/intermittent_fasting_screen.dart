import 'package:flutter/material.dart';

class IntermittentFastingScreen extends StatelessWidget {
  const IntermittentFastingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuno Intermitente'),
      ),
      body: const Center(
        child: Text('Pantalla de Ayuno Intermitente'),
      ),
    );
  }
}
