import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'dart:math';

class ObjectivesScreen extends StatefulWidget {
  const ObjectivesScreen({super.key});

  @override
  ObjectivesScreenState createState() => ObjectivesScreenState();
}

class ObjectivesScreenState extends State<ObjectivesScreen> {
  final TextEditingController _weightGoalController = TextEditingController();

  @override
  void dispose() {
    _weightGoalController.dispose();
    super.dispose();
  }

  double _calculateBmi(double weight, double height) {
    if (height <= 0) return 0;
    return weight / pow(height / 100, 2);
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Peso normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  String _getIdealWeightRange(double height) {
    if (height <= 0) return 'N/A';
    final double minWeight = 18.5 * pow(height / 100, 2);
    final double maxWeight = 24.9 * pow(height / 100, 2);
    return '${minWeight.toStringAsFixed(1)} kg - ${maxWeight.toStringAsFixed(1)} kg';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    Widget body;
    if (user == null || user.isGuest || user.height <= 0 || user.weight <= 0) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Por favor, complete su perfil para ver sus objetivos de peso.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      final double bmi = _calculateBmi(user.weight, user.height);
      final String bmiCategory = _getBmiCategory(bmi);
      final String idealWeightRange = _getIdealWeightRange(user.height);

      body = Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu Índice de Masa Corporal (IMC)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu IMC es ${bmi.toStringAsFixed(1)}, lo que se considera "$bmiCategory".',
            ),
            const SizedBox(height: 16),
            Text(
              'Peso Ideal Sugerido',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Basado en tu altura, un peso saludable para ti estaría en el rango de $idealWeightRange.',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _weightGoalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Mi Meta de Peso (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Guardar la meta de peso
              },
              child: const Text('Guardar Meta'),
            ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: body,
    );
  }
}
