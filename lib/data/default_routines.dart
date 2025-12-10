import 'package:hive/hive.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';

/// Rutinas predeterminadas para diferentes objetivos y niveles
class DefaultRoutines {
  
  /// Crear todas las rutinas predeterminadas
  static Future<void> createAll() async {
    final routinesBox = Hive.box<Routine>('routines');
    final exercisesBox = Hive.box<RoutineExercise>('routine_exercises');
    
    // Evitar duplicados
    final existingNames = routinesBox.values.map((r) => r.name).toSet();
    
    final defaultRoutines = [
      await _createFullBodyBeginner(exercisesBox),
      await _createUpperLowerSplit(exercisesBox),
      await _createPushPullLegs(exercisesBox),
      await _createCoreStrength(exercisesBox),
      await _createCardioHIIT(exercisesBox),
      await _createFlexibilityYoga(exercisesBox),
      await _createHomeWorkout(exercisesBox),
      await _createAdvancedCalisthenics(exercisesBox),
    ];
    
    for (var routine in defaultRoutines) {
      if (!existingNames.contains(routine.name)) {
        await routinesBox.add(routine);
      }
    }
  }

  /// 1. Rutina Full Body Principiante (3 días/semana)
  static Future<Routine> _createFullBodyBeginner(Box<RoutineExercise> exercisesBox) async {
    final exercises = HiveList<RoutineExercise>(exercisesBox);
    
    final exercisesList = [
      RoutineExercise(exerciseId: 'chest_001', sets: 3, reps: '10', restTime: 60),
      RoutineExercise(exerciseId: 'back_001', sets: 3, reps: '8', restTime: 60),
      RoutineExercise(exerciseId: 'legs_001', sets: 3, reps: '12', restTime: 90),
      RoutineExercise(exerciseId: 'shld_001', sets: 3, reps: '10', restTime: 60),
      RoutineExercise(exerciseId: 'abs_001', sets: 3, reps: '15', restTime: 45),
      RoutineExercise(exerciseId: 'arms_005', sets: 3, reps: '12', restTime: 45),
    ];
    
    for (var ex in exercisesList) {
      await exercisesBox.add(ex);
      exercises.add(ex);
    }
    
    return Routine(
      id: 'default_fullbody_beginner',
      name: '💪 Full Body Principiante',
      description: 'Rutina completa 3 días/semana. Ideal para comenzar.',
      exercises: exercises,
    );
  }

  /// 2. Rutina Upper/Lower Split (4 días/semana)
  static Future<Routine> _createUpperLowerSplit(Box<RoutineExercise> exercisesBox) async {
    final exercises = HiveList<RoutineExercise>(exercisesBox);
    
    final exercisesList = [
      // DÍA SUPERIOR
      RoutineExercise(exerciseId: 'chest_001', sets: 4, reps: '12', restTime: 60),
      RoutineExercise(exerciseId: 'back_013', sets: 4, reps: '10', restTime: 60),
      RoutineExercise(exerciseId: 'shld_012', sets: 3, reps: '10', restTime: 60),
      RoutineExercise(exerciseId: 'arms_013', sets: 3, reps: '8', restTime: 45),
      RoutineExercise(exerciseId: 'arms_005', sets: 3, reps: '12', restTime: 45),
      // DÍA INFERIOR
      RoutineExercise(exerciseId: 'legs_001', sets: 4, reps: '15', restTime: 90),
      RoutineExercise(exerciseId: 'legs_012', sets: 3, reps: '12', restTime: 60),
      RoutineExercise(exerciseId: 'legs_013', sets: 4, reps: '15', restTime: 60),
      RoutineExercise(exerciseId: 'legs_004', sets: 3, reps: '15', restTime: 45),
      RoutineExercise(exerciseId: 'abs_001', sets: 4, reps: '20', restTime: 45),
    ];
    
    for (var ex in exercisesList) {
      await exercisesBox.add(ex);
      exercises.add(ex);
    }
    
    return Routine(
      id: 'default_upper_lower',
      name: '🏋️ Upper/Lower Split',
      description: 'Divide superior e inferior. 4 días/semana.',
      exercises: exercises,
    );
  }

  /// 3. Rutina Push/Pull/Legs (6 días/semana)
  static Future<Routine> _createPushPullLegs(Box<RoutineExercise> exercisesBox) async {
    final exercises = HiveList<RoutineExercise>(exercisesBox);
    
    final exercisesList = [
      // PUSH (Empuje)
      RoutineExercise(exerciseId: 'chest_001', sets: 4, reps: '12', restTime: 60),
      RoutineExercise(exerciseId: 'chest_004', sets: 3, reps: '10', restTime: 60),
      RoutineExercise(exerciseId: 'shld_001', sets: 4, reps: '12', restTime: 60),
      RoutineExercise(exerciseId: 'shld_012', sets: 3, reps: '10', restTime: 60),
      RoutineExercise(exerciseId: 'arms_005', sets: 4, reps: '12', restTime: 45),
      // PULL (Tracción)
      RoutineExercise(exerciseId: 'back_001', sets: 4, reps: '8', restTime: 90),
      RoutineExercise(exerciseId: 'back_013', sets: 4, reps: '12', restTime: 60),
      RoutineExercise(exerciseId: 'back_012', sets: 3, reps: '15', restTime: 45),
      RoutineExercise(exerciseId: 'arms_001', sets: 4, reps: '12', restTime: 45),
      RoutineExercise(exerciseId: 'arms_013', sets: 3, reps: '8', restTime: 60),
      // LEGS (Piernas)
      RoutineExercise(exerciseId: 'legs_001', sets: 5, reps: '15', restTime: 90),
      RoutineExercise(exerciseId: 'legs_012', sets: 4, reps: '12', restTime: 60),
      RoutineExercise(exerciseId: 'legs_013', sets: 4, reps: '15', restTime: 60),
      RoutineExercise(exerciseId: 'legs_004', sets: 3, reps: '20', restTime: 45),
    ];
    
    for (var ex in exercisesList) {
      await exercisesBox.add(ex);
      exercises.add(ex);
    }
    
    return Routine(
      id: 'default_ppl',
      name: '💥 Push/Pull/Legs',
      description: 'División avanzada. 6 días/semana.',
      exercises: exercises,
    );
  }

  /// 4. Rutina Core & Abs
  static Future<Routine> _createCoreStrength(Box<RoutineExercise> exercisesBox) async {
    final exercises = HiveList<RoutineExercise>(exercisesBox);
    
    final exercisesList = [
      RoutineExercise(exerciseId: 'abs_001', sets: 4, reps: '20', restTime: 30),
      RoutineExercise(exerciseId: 'abs_002', sets: 3, reps: '60s', restTime: 30),
      RoutineExercise(exerciseId: 'abs_006', sets: 3, reps: '15', restTime: 30),
      RoutineExercise(exerciseId: 'abs_013', sets: 3, reps: '30s', restTime: 45),
      RoutineExercise(exerciseId: 'abs_011', sets: 3, reps: '20', restTime: 30),
      RoutineExercise(exerciseId: 'abs_009', sets: 4, reps: '30s', restTime: 30),
      RoutineExercise(exerciseId: 'abs_008', sets: 3, reps: '12', restTime: 45),
    ];
    
    for (var ex in exercisesList) {
      await exercisesBox.add(ex);
      exercises.add(ex);
    }
    
    return Routine(
      id: 'default_core',
      name: '🔥 Core Strength',
      description: 'Abdomen y core intenso. 20-30 min.',
      exercises: exercises,
    );
  }

  /// 5. Rutina Cardio HIIT
  static Future<Routine> _createCardioHIIT(Box<RoutineExercise> exercisesBox) async {
    final exercises = HiveList<RoutineExercise>(exercisesBox);
    
    final exercisesList = [
      RoutineExercise(exerciseId: 'crd_015', sets: 4, reps: '45s', restTime: 15),
      RoutineExercise(exerciseId: 'crd_014', sets: 4, reps: '30s', restTime: 15),
      RoutineExercise(exerciseId: 'crd_002', sets: 4, reps: '20', restTime: 15),
      RoutineExercise(exerciseId: 'crd_013', sets: 3, reps: '2min', restTime: 30),
      RoutineExercise(exerciseId: 'crd_003', sets: 4, reps: '30s', restTime: 15),
      RoutineExercise(exerciseId: 'crd_001', sets: 1, reps: '5min', restTime: 0),
    ];
    
    for (var ex in exercisesList) {
      await exercisesBox.add(ex);
      exercises.add(ex);
    }
    
    return Routine(
      id: 'default_hiit',
      name: '⚡ HIIT Cardio',
      description: 'Alta intensidad. Quema calorías rápido.',
      exercises: exercises,
    );
  }

  /// 6. Rutina Flexibilidad & Yoga
  static Future<Routine> _createFlexibilityYoga(Box<RoutineExercise> exercisesBox) async {
    final exercises = HiveList<RoutineExercise>(exercisesBox);
    
    final exercisesList = [
      RoutineExercise(exerciseId: 'yoga_001', sets: 3, reps: '30s', restTime: 15),
      RoutineExercise(exerciseId: 'yoga_002', sets: 3, reps: '45s', restTime: 15),
      RoutineExercise(exerciseId: 'yoga_003', sets: 2, reps: '60s', restTime: 20),
      RoutineExercise(exerciseId: 'yoga_005', sets: 3, reps: '30s', restTime: 15),
      RoutineExercise(exerciseId: 'yoga_007', sets: 2, reps: '45s', restTime: 20),
      RoutineExercise(exerciseId: 'yoga_008', sets: 2, reps: '60s', restTime: 20),
      RoutineExercise(exerciseId: 'yoga_009', sets: 1, reps: '2min', restTime: 0),
    ];
    
    for (var ex in exercisesList) {
      await exercisesBox.add(ex);
      exercises.add(ex);
    }
    
    return Routine(
      id: 'default_yoga',
      name: '🧘 Yoga & Flexibilidad',
      description: 'Estiramiento y movilidad. Recuperación.',
      exercises: exercises,
    );
  }

  /// 7. Rutina Casa Sin Equipo
  static Future<Routine> _createHomeWorkout(Box<RoutineExercise> exercisesBox) async {
    final exercises = HiveList<RoutineExercise>(exercisesBox);
    
    final exercisesList = [
      RoutineExercise(exerciseId: 'crd_015', sets: 3, reps: '30', restTime: 30),
      RoutineExercise(exerciseId: 'chest_001', sets: 4, reps: '15', restTime: 60),
      RoutineExercise(exerciseId: 'legs_001', sets: 4, reps: '20', restTime: 60),
      RoutineExercise(exerciseId: 'shld_012', sets: 3, reps: '10', restTime: 60),
      RoutineExercise(exerciseId: 'abs_001', sets: 3, reps: '15', restTime: 45),
      RoutineExercise(exerciseId: 'crd_014', sets: 3, reps: '30s', restTime: 30),
      RoutineExercise(exerciseId: 'abs_002', sets: 3, reps: '45s', restTime: 30),
    ];
    
    for (var ex in exercisesList) {
      await exercisesBox.add(ex);
      exercises.add(ex);
    }
    
    return Routine(
      id: 'default_home',
      name: '🏠 Workout en Casa',
      description: 'Sin equipo. Entrenamiento completo.',
      exercises: exercises,
    );
  }

  /// 8. Rutina Calistenia Avanzada
  static Future<Routine> _createAdvancedCalisthenics(Box<RoutineExercise> exercisesBox) async {
    final exercises = HiveList<RoutineExercise>(exercisesBox);
    
    final exercisesList = [
      RoutineExercise(exerciseId: 'chest_012', sets: 4, reps: '8', restTime: 90),
      RoutineExercise(exerciseId: 'chest_013', sets: 3, reps: '6', restTime: 90),
      RoutineExercise(exerciseId: 'back_001', sets: 4, reps: '10', restTime: 90),
      RoutineExercise(exerciseId: 'shld_013', sets: 3, reps: '5', restTime: 120),
      RoutineExercise(exerciseId: 'legs_014', sets: 3, reps: '8', restTime: 90),
      RoutineExercise(exerciseId: 'abs_012', sets: 3, reps: '5', restTime: 90),
      RoutineExercise(exerciseId: 'abs_013', sets: 3, reps: '45s', restTime: 60),
    ];
    
    for (var ex in exercisesList) {
      await exercisesBox.add(ex);
      exercises.add(ex);
    }
    
    return Routine(
      id: 'default_calisthenics',
      name: '🦾 Calistenia Avanzada',
      description: 'Movimientos avanzados. Fuerza funcional.',
      exercises: exercises,
    );
  }
}
