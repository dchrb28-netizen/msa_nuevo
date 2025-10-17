import 'package:flutter/material.dart';
import '../models/health_data.dart'; // Importa workoutGreen

/// Widget específico para mostrar el estado del último entrenamiento.
class WorkoutCard extends StatelessWidget {
  final String title;
  final String status;

  const WorkoutCard({super.key, required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icono de entrenamiento
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: workoutGreen.withAlpha(204),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Título y estado
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
