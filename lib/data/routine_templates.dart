// Templates de rutinas (no son objetos Hive, son recetas para crear rutinas)
class RoutineTemplate {
  final String name;
  final String description;
  final String level; // principiante, intermedio, avanzado
  final List<ExerciseTemplate> exercises;

  RoutineTemplate({
    required this.name,
    required this.description,
    required this.level,
    required this.exercises,
  });
}

class ExerciseTemplate {
  final String exerciseId;
  final int sets;
  final String reps;
  final int restTime;

  ExerciseTemplate({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.restTime,
  });
}

class RoutineTemplates {
  // Rutina para Principiantes - Cuerpo Completo
  static RoutineTemplate get beginnerFullBody => RoutineTemplate(
        name: 'Principiante - Cuerpo Completo',
        description: 'Rutina básica para comenzar. 3 días por semana.',
        level: 'principiante',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'chest_001', // Flexiones estándar
            sets: 3,
            reps: '8-12',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_001', // Sentadillas
            sets: 3,
            reps: '12-15',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'back_001', // Dominadas australianas
            sets: 3,
            reps: '8-10',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'shoulders_001', // Pike push-ups
            sets: 3,
            reps: '6-10',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'core_001', // Planchas
            sets: 3,
            reps: '20-30 seg',
            restTime: 60,
          ),
        ],
      );

  // Rutina Intermedia - Tren Superior
  static RoutineTemplate get intermediateUpper => RoutineTemplate(
        name: 'Intermedio - Tren Superior',
        description: 'Pecho, espalda, hombros y brazos. 2x semana.',
        level: 'intermedio',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'chest_003', // Flexiones declinadas
            sets: 4,
            reps: '10-15',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'chest_005', // Flexiones diamante
            sets: 3,
            reps: '8-12',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'back_001', // Dominadas australianas
            sets: 4,
            reps: '12-15',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'back_005', // Superman
            sets: 3,
            reps: '12-15',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'shoulders_001', // Pike push-ups
            sets: 4,
            reps: '10-12',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'biceps_001', // Curl con mochila
            sets: 3,
            reps: '10-12',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'triceps_001', // Fondos en silla
            sets: 3,
            reps: '10-12',
            restTime: 60,
          ),
        ],
      );

  // Rutina Intermedia - Tren Inferior
  static RoutineTemplate get intermediateLower => RoutineTemplate(
        name: 'Intermedio - Tren Inferior',
        description: 'Piernas, glúteos y core. 2x semana.',
        level: 'intermedio',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'legs_001', // Sentadillas
            sets: 4,
            reps: '12-15',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_002', // Sentadilla búlgara
            sets: 3,
            reps: '10-12',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_004', // Zancadas
            sets: 3,
            reps: '10-12',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'glutes_001', // Puente de glúteos
            sets: 4,
            reps: '12-15',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'glutes_003', // Hip Thrust
            sets: 3,
            reps: '12-15',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'calves_001', // Elevación de talones
            sets: 4,
            reps: '15-20',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'core_002', // Crunch abdominal
            sets: 3,
            reps: '15-20',
            restTime: 45,
          ),
        ],
      );

  // Rutina Avanzada - Push
  static RoutineTemplate get advancedPush => RoutineTemplate(
        name: 'Avanzado - Push (Empuje)',
        description: 'Pecho, hombros y tríceps. Alta intensidad.',
        level: 'avanzado',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'chest_003', // Flexiones declinadas
            sets: 5,
            reps: '12-15',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'chest_005', // Flexiones diamante
            sets: 4,
            reps: '10-12',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'chest_007', // Flexiones arqueras
            sets: 4,
            reps: '8-10',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'shoulders_001', // Pike push-ups
            sets: 4,
            reps: '12-15',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'shoulders_004', // Flexiones en pino
            sets: 3,
            reps: '6-8',
            restTime: 120,
          ),
          ExerciseTemplate(
            exerciseId: 'triceps_001', // Fondos en silla
            sets: 4,
            reps: '12-15',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'triceps_003', // Flexiones cerradas
            sets: 3,
            reps: '10-12',
            restTime: 60,
          ),
        ],
      );

  // Rutina Avanzada - Pull
  static RoutineTemplate get advancedPull => RoutineTemplate(
        name: 'Avanzado - Pull (Jalón)',
        description: 'Espalda y bíceps. Alta intensidad.',
        level: 'avanzado',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'back_001', // Dominadas australianas
            sets: 5,
            reps: '12-15',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'back_005', // Superman
            sets: 4,
            reps: '15-20',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'back_008', // Remo con toalla
            sets: 4,
            reps: '10-12',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'biceps_001', // Curl con mochila
            sets: 4,
            reps: '12-15',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'biceps_002', // Curl isométrico
            sets: 3,
            reps: '20-30 seg',
            restTime: 75,
          ),
        ],
      );

  // Rutina Avanzada - Legs
  static RoutineTemplate get advancedLegs => RoutineTemplate(
        name: 'Avanzado - Legs (Piernas)',
        description: 'Piernas completas. Alta intensidad.',
        level: 'avanzado',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'legs_001', // Sentadillas
            sets: 5,
            reps: '15-20',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_002', // Sentadilla búlgara
            sets: 4,
            reps: '12-15',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_003', // Sentadilla pistol
            sets: 4,
            reps: '6-10',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_008', // Saltos explosivos
            sets: 4,
            reps: '10-12',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'glutes_003', // Hip Thrust
            sets: 5,
            reps: '15-20',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'calves_001', // Elevación de talones
            sets: 5,
            reps: '20-25',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'core_001', // Planchas
            sets: 3,
            reps: '45-60 seg',
            restTime: 60,
          ),
        ],
      );

  // Rutina de Cardio HIIT
  static RoutineTemplate get cardioHIIT => RoutineTemplate(
        name: 'Cardio HIIT - Quema Grasa',
        description: 'Alta intensidad para quemar calorías.',
        level: 'todos',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'crd_001', // Jumping jacks
            sets: 3,
            reps: '20-30',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'crd_002', // Burpees
            sets: 3,
            reps: '8-15',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'crd_003', // Mountain climbers
            sets: 3,
            reps: '20-30',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'crd_004', // High knees
            sets: 3,
            reps: '20-30',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'crd_006', // Skaters
            sets: 3,
            reps: '15-20',
            restTime: 45,
          ),
        ],
      );

  // Lista de todas las rutinas
  static List<RoutineTemplate> get all => [
        beginnerFullBody,
        intermediateUpper,
        intermediateLower,
        advancedPush,
        advancedPull,
        advancedLegs,
        cardioHIIT,
      ];

  // Filtrar por nivel
  static List<RoutineTemplate> getByLevel(String level) {
    if (level.toLowerCase() == 'todos') return all;
    return all.where((r) => r.level.toLowerCase() == level.toLowerCase()).toList();
  }
}
