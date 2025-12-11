import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';

/// Servicio para ajustar rutinas cuando el peso corporal cambia
class RoutineAdjustmentService {
  static const double _significantWeightChangeKg = 2.0;

  /// Verifica si hay un cambio significativo de peso
  static bool hasSignificantWeightChange(double oldWeight, double newWeight) {
    final difference = (newWeight - oldWeight).abs();
    return difference >= _significantWeightChangeKg;
  }

  /// Calcula el porcentaje de cambio de peso
  static double calculateWeightChangePercentage(double oldWeight, double newWeight) {
    if (oldWeight == 0) return 0.0;
    return ((newWeight - oldWeight) / oldWeight) * 100;
  }

  /// Calcula el nuevo peso para un ejercicio basado en el cambio de peso corporal
  static double calculateAdjustedWeight(double currentExerciseWeight, double weightChangePercentage) {
    // Ajuste proporcional: si bajaste 5% de peso, se reduce 5% el peso en ejercicios
    final adjustment = currentExerciseWeight * (weightChangePercentage / 100);
    final newWeight = currentExerciseWeight + adjustment;
    
    // Redondear a 0.5kg más cercano
    return (newWeight * 2).round() / 2;
  }

  /// Obtiene todas las rutinas del usuario
  static Future<List<Routine>> getUserRoutines() async {
    final routineBox = Hive.box<Routine>('routines');
    return routineBox.values.toList();
  }

  /// Calcula los ajustes sugeridos para todas las rutinas
  static Map<String, RoutineAdjustment> calculateRoutineAdjustments(
    List<Routine> routines,
    double weightChangePercentage,
  ) {
    final adjustments = <String, RoutineAdjustment>{};

    for (final routine in routines) {
      final exerciseAdjustments = <ExerciseAdjustment>[];
      
      if (routine.exercises != null) {
        for (final exercise in routine.exercises!) {
          // Si el ejercicio tiene peso definido
          if (exercise.weight != null && exercise.weight! > 0) {
            final newWeight = calculateAdjustedWeight(
              exercise.weight!,
              weightChangePercentage,
            );
            
            // Solo incluir si hay cambio significativo (>0.5kg)
            if ((newWeight - exercise.weight!).abs() >= 0.5) {
              exerciseAdjustments.add(ExerciseAdjustment(
                exerciseName: exercise.exercise.name,
                oldWeight: exercise.weight!,
                newWeight: newWeight,
              ));
            }
          }
        }
      }

      if (exerciseAdjustments.isNotEmpty) {
        adjustments[routine.id] = RoutineAdjustment(
          routineId: routine.id,
          routineName: routine.name,
          exercises: exerciseAdjustments,
        );
      }
    }

    return adjustments;
  }

  /// Aplica los ajustes a las rutinas en la base de datos
  static Future<int> applyAdjustments(Map<String, RoutineAdjustment> adjustments) async {
    final routineBox = Hive.box<Routine>('routines');
    int updatedCount = 0;

    for (final adjustment in adjustments.values) {
      final routine = routineBox.get(adjustment.routineId);
      if (routine == null || routine.exercises == null) continue;

      // Actualizar pesos en los ejercicios existentes
      for (final exercise in routine.exercises!) {
        final exerciseAdjustment = adjustment.exercises.firstWhere(
          (adj) => adj.exerciseName == exercise.exercise.name,
          orElse: () => ExerciseAdjustment(
            exerciseName: exercise.exercise.name,
            oldWeight: exercise.weight ?? 0,
            newWeight: exercise.weight ?? 0,
          ),
        );

        // Solo actualizar si hubo cambio
        if (exerciseAdjustment.oldWeight != exerciseAdjustment.newWeight) {
          exercise.weight = exerciseAdjustment.newWeight;
        }
      }

      // Guardar la rutina actualizada
      await routine.save();
      updatedCount++;
    }

    return updatedCount;
  }
}

/// Información sobre el ajuste sugerido para una rutina
class RoutineAdjustment {
  final String routineId;
  final String routineName;
  final List<ExerciseAdjustment> exercises;

  RoutineAdjustment({
    required this.routineId,
    required this.routineName,
    required this.exercises,
  });
}

/// Información sobre el ajuste de peso de un ejercicio
class ExerciseAdjustment {
  final String exerciseName;
  final double oldWeight;
  final double newWeight;

  ExerciseAdjustment({
    required this.exerciseName,
    required this.oldWeight,
    required this.newWeight,
  });

  double get difference => newWeight - oldWeight;
  String get differenceText {
    final diff = difference;
    return diff > 0 ? '+${diff.toStringAsFixed(1)}' : diff.toStringAsFixed(1);
  }
}
