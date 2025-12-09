import 'package:hive/hive.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';

/// Rutinas predeterminadas para diferentes objetivos y niveles
class DefaultRoutines {
  
  /// Crear todas las rutinas predeterminadas
  static Future<void> createAll() async {
    final routinesBox = Hive.box<Routine>('routines');
    
    // Evitar duplicados
    final existingNames = routinesBox.values.map((r) => r.name).toSet();
    
    final defaultRoutines = [
      _createFullBodyBeginner(),
      _createUpperLowerSplit(),
      _createPushPullLegs(),
      _createCoreStrength(),
      _createCardioHIIT(),
      _createFlexibilityYoga(),
      _createHomeWorkout(),
      _createAdvancedCalisthenics(),
    ];
    
    for (var routine in defaultRoutines) {
      if (!existingNames.contains(routine.name)) {
        await routinesBox.add(routine);
      }
    }
  }

  /// 1. Rutina Full Body Principiante (3 días/semana)
  static Routine _createFullBodyBeginner() {
    return Routine(
      id: 'default_fullbody_beginner',
      name: '💪 Full Body Principiante',
      description: 'Rutina completa 3 días/semana. Ideal para comenzar.',
      exercises: null,
    )..exercises = (HiveList(Hive.box<RoutineExercise>('routine_exercises'))
      ..addAll([
        RoutineExercise(exerciseId: 'chest_001', sets: 3, reps: '10', restTime: 60),
        RoutineExercise(exerciseId: 'back_001', sets: 3, reps: '8', restTime: 60),
        RoutineExercise(exerciseId: 'legs_001', sets: 3, reps: '12', restTime: 90),
        RoutineExercise(exerciseId: 'shoulders_001', sets: 3, reps: '10', restTime: 60),
        RoutineExercise(exerciseId: 'abs_001', sets: 3, reps: '15', restTime: 45),
        RoutineExercise(exerciseId: 'arms_005', sets: 3, reps: '12', restTime: 45),
      ]));
  }

  /// 2. Rutina Upper/Lower Split (4 días/semana)
  static Routine _createUpperLowerSplit() {
    return Routine(
      id: 'default_upper_lower',
      name: '🏋️ Upper/Lower Split',
      description: 'Divide superior e inferior. 4 días/semana.',
      exercises: null,
    )..exercises = (HiveList(Hive.box<RoutineExercise>('routine_exercises'))
      ..addAll([
        // DÍA SUPERIOR
        RoutineExercise(exerciseId: 'chest_001', sets: 4, reps: '12', restTime: 60),
        RoutineExercise(exerciseId: 'back_013', sets: 4, reps: '10', restTime: 60),
        RoutineExercise(exerciseId: 'shoulders_012', sets: 3, reps: '10', restTime: 60),
        RoutineExercise(exerciseId: 'arms_013', sets: 3, reps: '8', restTime: 45),
        RoutineExercise(exerciseId: 'arms_005', sets: 3, reps: '12', restTime: 45),
        // DÍA INFERIOR
        RoutineExercise(exerciseId: 'legs_001', sets: 4, reps: '15', restTime: 90),
        RoutineExercise(exerciseId: 'legs_012', sets: 3, reps: '12', restTime: 60),
        RoutineExercise(exerciseId: 'legs_013', sets: 4, reps: '15', restTime: 60),
        RoutineExercise(exerciseId: 'legs_004', sets: 3, reps: '15', restTime: 45),
        RoutineExercise(exerciseId: 'abs_001', sets: 4, reps: '20', restTime: 45),
      ]));
  }

  /// 3. Rutina Push/Pull/Legs (6 días/semana)
  static Routine _createPushPullLegs() {
    return Routine(
      id: 'default_ppl',
      name: '💥 Push/Pull/Legs',
      description: 'División avanzada. 6 días/semana.',
      exercises: null,
    )..exercises = (HiveList(Hive.box<RoutineExercise>('routine_exercises'))
      ..addAll([
        // PUSH (Empuje)
        RoutineExercise(exerciseId: 'chest_001', sets: 4, reps: '12', restTime: 60),
        RoutineExercise(exerciseId: 'chest_004', sets: 3, reps: '10', restTime: 60),
        RoutineExercise(exerciseId: 'shoulders_001', sets: 4, reps: '12', restTime: 60),
        RoutineExercise(exerciseId: 'shoulders_012', sets: 3, reps: '10', restTime: 60),
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
      ]));
  }

  /// 4. Rutina Core & Abs
  static Routine _createCoreStrength() {
    return Routine(
      id: 'default_core',
      name: '🔥 Core Strength',
      description: 'Abdomen y core intenso. 20-30 min.',
      exercises: null,
    )..exercises = (HiveList(Hive.box<RoutineExercise>('routine_exercises'))
      ..addAll([
        RoutineExercise(exerciseId: 'abs_001', sets: 4, reps: '20', restTime: 30),
        RoutineExercise(exerciseId: 'abs_002', sets: 3, reps: '60s', restTime: 30),
        RoutineExercise(exerciseId: 'abs_006', sets: 3, reps: '15', restTime: 30),
        RoutineExercise(exerciseId: 'abs_013', sets: 3, reps: '30s', restTime: 45),
        RoutineExercise(exerciseId: 'abs_011', sets: 3, reps: '20', restTime: 30),
        RoutineExercise(exerciseId: 'abs_009', sets: 4, reps: '30s', restTime: 30),
        RoutineExercise(exerciseId: 'abs_008', sets: 3, reps: '12', restTime: 45),
      ]));
  }

  /// 5. Rutina Cardio HIIT
  static Routine _createCardioHIIT() {
    return Routine(
      id: 'default_hiit',
      name: '⚡ HIIT Cardio',
      description: 'Alta intensidad. Quema calorías rápido.',
      exercises: null,
    )..exercises = (HiveList(Hive.box<RoutineExercise>('routine_exercises'))
      ..addAll([
        RoutineExercise(exerciseId: 'cardio_015', sets: 4, reps: '45s', restTime: 15),
        RoutineExercise(exerciseId: 'cardio_014', sets: 4, reps: '30s', restTime: 15),
        RoutineExercise(exerciseId: 'cardio_002', sets: 4, reps: '20', restTime: 15),
        RoutineExercise(exerciseId: 'cardio_013', sets: 3, reps: '2min', restTime: 30),
        RoutineExercise(exerciseId: 'cardio_003', sets: 4, reps: '30s', restTime: 15),
        RoutineExercise(exerciseId: 'cardio_001', sets: 1, reps: '5min', restTime: 0),
      ]));
  }

  /// 6. Rutina Flexibilidad & Yoga
  static Routine _createFlexibilityYoga() {
    return Routine(
      id: 'default_yoga',
      name: '🧘 Yoga & Flexibilidad',
      description: 'Estiramiento y movilidad. Recuperación.',
      exercises: null,
    )..exercises = (HiveList(Hive.box<RoutineExercise>('routine_exercises'))
      ..addAll([
        RoutineExercise(exerciseId: 'yoga_001', sets: 3, reps: '30s', restTime: 15),
        RoutineExercise(exerciseId: 'yoga_002', sets: 3, reps: '45s', restTime: 15),
        RoutineExercise(exerciseId: 'yoga_003', sets: 2, reps: '60s', restTime: 20),
        RoutineExercise(exerciseId: 'yoga_005', sets: 3, reps: '30s', restTime: 15),
        RoutineExercise(exerciseId: 'yoga_007', sets: 2, reps: '45s', restTime: 20),
        RoutineExercise(exerciseId: 'yoga_008', sets: 2, reps: '60s', restTime: 20),
        RoutineExercise(exerciseId: 'yoga_009', sets: 1, reps: '2min', restTime: 0),
      ]));
  }

  /// 7. Rutina Casa Sin Equipo
  static Routine _createHomeWorkout() {
    return Routine(
      id: 'default_home',
      name: '🏠 Workout en Casa',
      description: 'Sin equipo. Entrenamiento completo.',
      exercises: null,
    )..exercises = (HiveList(Hive.box<RoutineExercise>('routine_exercises'))
      ..addAll([
        RoutineExercise(exerciseId: 'cardio_015', sets: 3, reps: '30', restTime: 30),
        RoutineExercise(exerciseId: 'chest_001', sets: 4, reps: '15', restTime: 60),
        RoutineExercise(exerciseId: 'legs_001', sets: 4, reps: '20', restTime: 60),
        RoutineExercise(exerciseId: 'shoulders_012', sets: 3, reps: '10', restTime: 60),
        RoutineExercise(exerciseId: 'abs_001', sets: 3, reps: '15', restTime: 45),
        RoutineExercise(exerciseId: 'cardio_014', sets: 3, reps: '30s', restTime: 30),
        RoutineExercise(exerciseId: 'abs_002', sets: 3, reps: '45s', restTime: 30),
      ]));
  }

  /// 8. Rutina Calistenia Avanzada
  static Routine _createAdvancedCalisthenics() {
    return Routine(
      id: 'default_calisthenics',
      name: '🦾 Calistenia Avanzada',
      description: 'Movimientos avanzados. Fuerza funcional.',
      exercises: null,
    )..exercises = (HiveList(Hive.box<RoutineExercise>('routine_exercises'))
      ..addAll([
        RoutineExercise(exerciseId: 'chest_012', sets: 4, reps: '8', restTime: 90),
        RoutineExercise(exerciseId: 'chest_013', sets: 3, reps: '6', restTime: 90),
        RoutineExercise(exerciseId: 'back_001', sets: 4, reps: '10', restTime: 90),
        RoutineExercise(exerciseId: 'shoulders_013', sets: 3, reps: '5', restTime: 120),
        RoutineExercise(exerciseId: 'legs_014', sets: 3, reps: '8', restTime: 90),
        RoutineExercise(exerciseId: 'abs_012', sets: 3, reps: '5', restTime: 90),
        RoutineExercise(exerciseId: 'abs_013', sets: 3, reps: '45s', restTime: 60),
      ]));
  }
}
