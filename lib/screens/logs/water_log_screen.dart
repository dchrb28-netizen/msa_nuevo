import 'package:flutter/material.dart';

class WaterLogScreen extends StatelessWidget {
  const WaterLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Agua'),
      ),
      body: const Center(
        child: Text('Aquí podrás registrar tu ingesta de agua.'),
      ),
    );
  }
}
