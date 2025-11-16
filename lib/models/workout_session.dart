// lib/models/workout_session.dart
import 'package:uuid/uuid.dart';

// Representa los datos registrados para una sola serie de un ejercicio.
class SetLog {
  final int reps;
  final double weight;

  SetLog({required this.reps, required this.weight});

  @override
  String toString() {
    // Ayudante para formatear la cadena de salida
    return '$reps reps con $weight kg';
  }
}

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

  WorkoutSession({
    required this.routineName,
    required this.date,
    required this.performedExercises,
    String? id, // El ID es ahora opcional en el constructor
  }) : id = id ?? const Uuid().v4(); // Genera un ID v4 si no se proporciona uno
}
