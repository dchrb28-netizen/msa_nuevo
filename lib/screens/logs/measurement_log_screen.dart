import 'package:flutter/material.dart';

class MeasurementLogScreen extends StatelessWidget {
  const MeasurementLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Medidas'),
      ),
      body: const Center(
        child: Text('Aquí podrás registrar tus medidas corporales.'),
      ),
    );
  }
}
