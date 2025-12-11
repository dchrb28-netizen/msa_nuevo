// lib/models/workout_session.dart
import 'package:uuid/uuid.dart';
import 'package:myapp/models/set_log.dart';

// Representa todas las series registradas para un solo ejercicio dentro de una sesión de entrenamiento.
class PerformedExerciseLog {
  final String exerciseName;
  final List<SetLog> sets;

  PerformedExerciseLog({required this.exerciseName, required this.sets});
}

// Representa una sesión de entrenamiento completa que ha sido finalizada y registrada.
class WorkoutSession {
  final String id;
  final String routineName;
  final DateTime date;
  final List<PerformedExerciseLog> performedExercises;
  final int durationInMinutes; // Añadido para guardar la duración

  WorkoutSession({
    required this.routineName,
    required this.date,
    required this.performedExercises,
    required this.durationInMinutes, // Requerido en el constructor
    String? id,
  }) : id = id ?? const Uuid().v4();
}
