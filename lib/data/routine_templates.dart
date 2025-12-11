// Templates de rutinas (no son objetos Hive, son recetas para crear rutinas)
class RoutineTemplate {
  final String name;
  final String description;
  final String level; // principiante, intermedio, avanzado
  final List<ExerciseTemplate> exercises;
  final List<String> muscleGroups; // Grupos musculares trabajados
  final String? duration; // Duración estimada en minutos

  RoutineTemplate({
    required this.name,
    required this.description,
    required this.level,
    required this.exercises,
    this.muscleGroups = const [],
    this.duration,
  });

  // Calcula el tiempo total estimado en minutos
  int get estimatedDurationMinutes {
    if (duration != null) {
      // Si ya está especificado, usarlo
      final match = RegExp(r'(\d+)').firstMatch(duration!);
      if (match != null) return int.parse(match.group(1)!);
    }
    
    // Calcular basado en ejercicios y descansos
    int totalSeconds = 0;
    for (var exercise in exercises) {
      // Tiempo estimado por set (30 segundos por set promedio)
      totalSeconds += exercise.sets * 30;
      // Tiempo de descanso
      totalSeconds += (exercise.sets - 1) * exercise.restTime;
    }
    return (totalSeconds / 60).ceil();
  }

  String get estimatedDurationRange {
    final base = estimatedDurationMinutes;
    return '~${base}-${base + 5} min';
  }
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
        muscleGroups: ['Pecho', 'Piernas', 'Espalda', 'Hombros', 'Abdomen'],
        duration: '25-30 min',
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
            exerciseId: 'shld_001', // Pike push-ups
            sets: 3,
            reps: '6-10',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_001', // Planchas
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
        muscleGroups: ['Pecho', 'Espalda', 'Hombros', 'Brazos'],
        duration: '35-40 min',
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
            exerciseId: 'shld_001', // Pike push-ups
            sets: 4,
            reps: '10-12',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'arms_001', // Curl con mochila
            sets: 3,
            reps: '10-12',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'arms_006', // Fondos en silla
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
        muscleGroups: ['Piernas', 'Glúteos', 'Abdomen'],
        duration: '35-40 min',
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
            exerciseId: 'legs_007', // Puente de glúteos
            sets: 4,
            reps: '12-15',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_007', // Puente de glúteos
            sets: 3,
            reps: '12-15',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_008', // Elevación de talones
            sets: 4,
            reps: '15-20',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_002', // Crunch abdominal
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
        muscleGroups: ['Pecho', 'Hombros', 'Brazos'],
        duration: '45-50 min',
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
            exerciseId: 'shld_001', // Pike push-ups
            sets: 4,
            reps: '12-15',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'shld_004', // Flexiones en pino
            sets: 3,
            reps: '6-8',
            restTime: 120,
          ),
          ExerciseTemplate(
            exerciseId: 'arms_006', // Fondos en silla
            sets: 4,
            reps: '12-15',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'chest_005', // Flexiones diamante (tríceps)
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
        muscleGroups: ['Espalda', 'Brazos'],
        duration: '35-40 min',
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
            exerciseId: 'arms_001', // Curl con mochila
            sets: 4,
            reps: '12-15',
            restTime: 60,
          ),
          ExerciseTemplate(
            exerciseId: 'arms_002', // Curl martillo
            sets: 3,
            reps: '12-15',
            restTime: 60,
          ),
        ],
      );

  // Rutina Avanzada - Legs
  static RoutineTemplate get advancedLegs => RoutineTemplate(
        name: 'Avanzado - Legs (Piernas)',
        description: 'Piernas completas. Alta intensidad.',
        level: 'avanzado',
        muscleGroups: ['Piernas', 'Glúteos', 'Pantorrillas', 'Abdomen'],
        duration: '45-50 min',
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
            exerciseId: 'legs_010', // Jump squat
            sets: 4,
            reps: '10-12',
            restTime: 90,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_007', // Puente de glúteos
            sets: 5,
            reps: '15-20',
            restTime: 75,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_008', // Elevación de talones
            sets: 5,
            reps: '20-25',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_001', // Planchas
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
        muscleGroups: ['Cardio', 'Cuerpo Completo'],
        duration: '15-20 min',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'crd_001', // Jumping jacks
            sets: 3,
            reps: '20-30',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'crd_004', // Burpees
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
            exerciseId: 'crd_002', // High knees
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

  // Rutina Express 10 Minutos
  static RoutineTemplate get express10min => RoutineTemplate(
        name: 'Express - 10 Minutos',
        description: 'Rutina rápida para días ocupados. Cuerpo completo.',
        level: 'todos',
        muscleGroups: ['Cuerpo Completo'],
        duration: '10-12 min',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'chest_001', // Flexiones estándar
            sets: 2,
            reps: '10-15',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_001', // Sentadillas
            sets: 2,
            reps: '15-20',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_001', // Plancha
            sets: 2,
            reps: '30-45s',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'crd_004', // Burpees
            sets: 2,
            reps: '8-12',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'back_005', // Superman
            sets: 2,
            reps: '12-15',
            restTime: 30,
          ),
        ],
      );

  // Rutina Cardio Bajo Impacto
  static RoutineTemplate get cardioLowImpact => RoutineTemplate(
        name: 'Cardio Bajo Impacto',
        description: 'Cardio suave para recuperación o principiantes.',
        level: 'principiante',
        muscleGroups: ['Cardio', 'Movilidad'],
        duration: '20-25 min',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'crd_001', // Jumping jacks (versión moderada)
            sets: 3,
            reps: '15-20',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'crd_002', // High knees (controlado)
            sets: 3,
            reps: '15-20',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_001', // Sentadillas
            sets: 3,
            reps: '12-15',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'legs_006', // Step-ups
            sets: 3,
            reps: '10 por pierna',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'crd_003', // Mountain climbers (lento)
            sets: 3,
            reps: '15-20',
            restTime: 60,
          ),
        ],
      );

  // Rutina Core Intenso
  static RoutineTemplate get coreIntense => RoutineTemplate(
        name: 'Core Intenso - Abdomen',
        description: 'Enfocada 100% en abdomen y core. Para todos los niveles.',
        level: 'intermedio',
        muscleGroups: ['Abdomen', 'Core'],
        duration: '20-25 min',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'abs_001', // Plancha frontal
            sets: 3,
            reps: '45-60s',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_002', // Crunches
            sets: 4,
            reps: '15-20',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_003', // Elevaciones de piernas
            sets: 3,
            reps: '12-15',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_004', // Bicicleta abdominal
            sets: 3,
            reps: '20-30',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_005', // Russian twist
            sets: 3,
            reps: '20-30',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_007', // Plancha lateral
            sets: 3,
            reps: '30-45s por lado',
            restTime: 45,
          ),
          ExerciseTemplate(
            exerciseId: 'abs_010', // Dead bug
            sets: 3,
            reps: '12-15',
            restTime: 45,
          ),
        ],
      );

  // Rutina Movilidad y Estiramiento
  static RoutineTemplate get mobilityStretch => RoutineTemplate(
        name: 'Movilidad y Estiramiento',
        description: 'Yoga y estiramientos para flexibilidad y recuperación.',
        level: 'todos',
        muscleGroups: ['Movilidad', 'Flexibilidad', 'Cuerpo Completo'],
        duration: '25-30 min',
        exercises: [
          ExerciseTemplate(
            exerciseId: 'yoga_001', // Perro boca abajo
            sets: 3,
            reps: '30-45s',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'yoga_002', // Guerrero I
            sets: 2,
            reps: '30s por lado',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'yoga_003', // Guerrero II
            sets: 2,
            reps: '30s por lado',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'yoga_004', // Postura del triángulo
            sets: 2,
            reps: '30s por lado',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'yoga_005', // Postura del gato-vaca
            sets: 3,
            reps: '10-12',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'yoga_006', // Postura del niño
            sets: 2,
            reps: '45-60s',
            restTime: 30,
          ),
          ExerciseTemplate(
            exerciseId: 'yoga_008', // Torsión espinal
            sets: 2,
            reps: '30s por lado',
            restTime: 30,
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
        express10min,
        cardioLowImpact,
        coreIntense,
        mobilityStretch,
      ];

  // Filtrar por nivel
  static List<RoutineTemplate> getByLevel(String level) {
    if (level.toLowerCase() == 'todos') return all;
    return all.where((r) => r.level.toLowerCase() == level.toLowerCase()).toList();
  }
}
