import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grupo Muscular: ${exercise.muscleGroup}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Equipamiento: ${exercise.equipment}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Agrega más detalles aquí si es necesario
          ],
        ),
      ),
    );
  }
}
