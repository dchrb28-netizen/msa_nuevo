import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class RoutineRecommendationService {
  static const _uuid = Uuid();

  // Calcular IMC
  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  // Determinar nivel de condición física
  static String determineFitnessLevel(UserProfile profile) {
    final age = profile.age ?? 25;
    final bmi = calculateBMI(profile.weight ?? 70, profile.height ?? 170);
    
    // Lógica para determinar nivel
    if (age < 30 && bmi >= 18.5 && bmi <= 24.9) {
      return 'intermedio';
    } else if (age >= 50 || bmi < 18.5 || bmi > 30) {
      return 'principiante';
    } else if (age >= 30 && age < 50 && bmi >= 25 && bmi <= 29.9) {
      return 'principiante';
    } else if (age < 40 && bmi >= 18.5 && bmi <= 27) {
      return 'intermedio';
    }
    return 'principiante';
  }

  // Ajustar volumen de entrenamiento según edad
  static Map<String, int> getVolumeAdjustment(int age) {
    if (age < 25) {
      return {'sets': 4, 'reps': 12, 'rest': 60};
    } else if (age < 40) {
      return {'sets': 4, 'reps': 10, 'rest': 75};
    } else if (age < 55) {
      return {'sets': 3, 'reps': 10, 'rest': 90};
    } else {
      return {'sets': 3, 'reps': 8, 'rest': 120};
    }
  }

  // Ajustar según sexo
  static Map<String, dynamic> getSexAdjustment(String sex) {
    if (sex.toLowerCase() == 'masculino' || sex.toLowerCase() == 'hombre') {
      return {
        'focusUpper': 0.6, // 60% tren superior
        'focusLower': 0.4, // 40% tren inferior
        'strengthMultiplier': 1.2,
      };
    } else {
      return {
        'focusUpper': 0.4, // 40% tren superior
        'focusLower': 0.6, // 60% tren inferior
        'strengthMultiplier': 1.0,
      };
    }
  }

  // Generar rutina personalizada - Cuerpo Completo
  static Routine generateFullBodyRoutine(UserProfile profile) {
    final age = profile.age ?? 25;
    final sex = profile.sex ?? 'Masculino';
    final level = determineFitnessLevel(profile);
    final volume = getVolumeAdjustment(age);
    final sexAdj = getSexAdjustment(sex);

    final baseSets = volume['sets']!;
    final baseReps = volume['reps']!;
    final baseRest = volume['rest']!;

    List<RoutineExercise> exercises = [];

    // Ejercicios según enfoque de sexo
    if (sexAdj['focusUpper'] > 0.5) {
      // Mayor enfoque en tren superior (típicamente masculino)
      exercises = [
        // Pecho - 2 ejercicios
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: level == 'principiante' ? 'chest_001' : 'chest_003',
          sets: baseSets,
          reps: baseReps,
          restSeconds: baseRest,
          notes: 'Ajusta la dificultad según tu nivel',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: level == 'principiante' ? 'chest_002' : 'chest_005',
          sets: baseSets - 1,
          reps: baseReps - 2,
          restSeconds: baseRest,
          notes: 'Mantén buena forma',
        ),
        // Espalda - 2 ejercicios
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'back_001',
          sets: baseSets,
          reps: baseReps,
          restSeconds: baseRest,
          notes: 'Contrae los omóplatos',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'back_005',
          sets: baseSets - 1,
          reps: baseReps + 2,
          restSeconds: baseRest - 15,
          notes: 'Fortalece la espalda baja',
        ),
        // Hombros
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'shoulders_001',
          sets: baseSets,
          reps: baseReps - 2,
          restSeconds: baseRest,
          notes: 'Mantén la V invertida',
        ),
        // Brazos
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'triceps_001',
          sets: baseSets - 1,
          reps: baseReps,
          restSeconds: baseRest - 15,
          notes: 'Codos hacia atrás',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'biceps_001',
          sets: baseSets - 1,
          reps: baseReps,
          restSeconds: baseRest - 15,
          notes: 'Movimiento controlado',
        ),
        // Piernas - 1 ejercicio compuesto
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'legs_001',
          sets: baseSets,
          reps: baseReps + 3,
          restSeconds: baseRest + 15,
          notes: 'Ejercicio fundamental',
        ),
        // Core
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'core_001',
          sets: baseSets - 1,
          reps: (baseReps * 3).clamp(20, 60),
          restSeconds: baseRest - 15,
          notes: 'Mantén el cuerpo recto',
        ),
      ];
    } else {
      // Mayor enfoque en tren inferior (típicamente femenino)
      exercises = [
        // Piernas - 3 ejercicios
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'legs_001',
          sets: baseSets,
          reps: baseReps + 3,
          restSeconds: baseRest + 15,
          notes: 'Base fundamental',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: level == 'principiante' ? 'legs_004' : 'legs_002',
          sets: baseSets,
          reps: baseReps,
          restSeconds: baseRest + 15,
          notes: 'Enfoque en cada pierna',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'legs_008',
          sets: baseSets - 1,
          reps: baseReps - 2,
          restSeconds: baseRest + 15,
          notes: 'Explosividad',
        ),
        // Glúteos - 2 ejercicios
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'glutes_001',
          sets: baseSets,
          reps: baseReps + 3,
          restSeconds: baseRest,
          notes: 'Contrae arriba 2 segundos',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'glutes_003',
          sets: baseSets,
          reps: baseReps + 2,
          restSeconds: baseRest,
          notes: 'Hip thrust efectivo',
        ),
        // Pecho - 1 ejercicio
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: level == 'principiante' ? 'chest_002' : 'chest_001',
          sets: baseSets - 1,
          reps: baseReps,
          restSeconds: baseRest,
          notes: 'Trabajo de pecho',
        ),
        // Espalda - 1 ejercicio
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'back_001',
          sets: baseSets - 1,
          reps: baseReps,
          restSeconds: baseRest,
          notes: 'Fortalece la espalda',
        ),
        // Core - 2 ejercicios
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'core_001',
          sets: baseSets,
          reps: (baseReps * 3).clamp(20, 60),
          restSeconds: baseRest - 15,
          notes: 'Plancha isométrica',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'core_007',
          sets: baseSets - 1,
          reps: baseReps + 5,
          restSeconds: baseRest - 15,
          notes: 'Abdominales oblicuos',
        ),
      ];
    }

    final bmi = calculateBMI(profile.weight ?? 70, profile.height ?? 170);
    final bmiCategory = bmi < 18.5 ? 'bajo peso' : 
                       bmi < 25 ? 'peso normal' : 
                       bmi < 30 ? 'sobrepeso' : 'obesidad';

    return Routine(
      id: _uuid.v4(),
      name: 'Mi Rutina Personalizada - Cuerpo Completo',
      description: 'Rutina adaptada a: ${profile.sex}, ${age} años, IMC ${bmi.toStringAsFixed(1)} ($bmiCategory). Nivel: $level.',
      createdAt: DateTime.now(),
      exercises: exercises,
    );
  }

  // Generar rutina de cardio personalizada
  static Routine generateCardioRoutine(UserProfile profile) {
    final age = profile.age ?? 25;
    final bmi = calculateBMI(profile.weight ?? 70, profile.height ?? 170);
    final level = determineFitnessLevel(profile);
    
    // Ajustar intensidad según edad y BMI
    int sets = 3;
    int baseReps = 20;
    int rest = 45;
    
    if (age > 50) {
      sets = 2;
      rest = 60;
    }
    
    if (bmi > 30) {
      baseReps = 15;
      rest = 60;
    } else if (bmi < 20) {
      baseReps = 25;
    }

    return Routine(
      id: _uuid.v4(),
      name: 'Mi Rutina de Cardio Personalizada',
      description: 'Cardio HIIT adaptado a tu perfil. Quema calorías y mejora resistencia.',
      createdAt: DateTime.now(),
      exercises: [
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'cardio_001',
          sets: sets,
          reps: baseReps + 5,
          restSeconds: rest - 15,
          notes: 'Calentamiento activo',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'cardio_002',
          sets: sets,
          reps: level == 'principiante' ? (baseReps ~/ 2) : baseReps,
          restSeconds: rest + 15,
          notes: 'Alta intensidad - ajusta según tu nivel',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'cardio_003',
          sets: sets,
          reps: baseReps,
          restSeconds: rest,
          notes: 'Mantén el ritmo',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'cardio_004',
          sets: sets,
          reps: baseReps,
          restSeconds: rest,
          notes: 'Rodillas altas',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'cardio_006',
          sets: sets,
          reps: baseReps - 5,
          restSeconds: rest,
          notes: 'Lateral explosivo',
        ),
        if (level != 'principiante')
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_008',
            sets: sets - 1,
            reps: baseReps - 5,
            restSeconds: rest + 15,
            notes: 'Finalización fuerte',
          ),
      ],
    );
  }

  // Generar rutina de fuerza tren superior
  static Routine generateUpperBodyRoutine(UserProfile profile) {
    final age = profile.age ?? 25;
    final sex = profile.sex ?? 'Masculino';
    final level = determineFitnessLevel(profile);
    final volume = getVolumeAdjustment(age);

    final baseSets = volume['sets']!;
    final baseReps = volume['reps']!;
    final baseRest = volume['rest']!;

    return Routine(
      id: _uuid.v4(),
      name: 'Mi Rutina - Tren Superior',
      description: 'Pecho, espalda, hombros y brazos personalizados.',
      createdAt: DateTime.now(),
      exercises: [
        // Pecho
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: level == 'principiante' ? 'chest_001' : 'chest_003',
          sets: baseSets,
          reps: baseReps,
          restSeconds: baseRest,
          notes: 'Ejercicio principal de pecho',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: level == 'principiante' ? 'chest_002' : 'chest_005',
          sets: baseSets - 1,
          reps: baseReps - 2,
          restSeconds: baseRest,
          notes: 'Variación de pecho',
        ),
        // Espalda
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'back_001',
          sets: baseSets,
          reps: baseReps,
          restSeconds: baseRest,
          notes: 'Trabajo de espalda',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'back_005',
          sets: baseSets - 1,
          reps: baseReps + 3,
          restSeconds: baseRest - 15,
          notes: 'Espalda baja',
        ),
        // Hombros
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'shoulders_001',
          sets: baseSets,
          reps: baseReps - 2,
          restSeconds: baseRest,
          notes: 'Desarrollo de hombros',
        ),
        // Bíceps
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'biceps_001',
          sets: baseSets - 1,
          reps: baseReps,
          restSeconds: baseRest - 15,
          notes: 'Curl de bíceps',
        ),
        // Tríceps
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'triceps_001',
          sets: baseSets - 1,
          reps: baseReps,
          restSeconds: baseRest - 15,
          notes: 'Extensión de tríceps',
        ),
      ],
    );
  }

  // Generar rutina de fuerza tren inferior
  static Routine generateLowerBodyRoutine(UserProfile profile) {
    final age = profile.age ?? 25;
    final sex = profile.sex ?? 'Masculino';
    final level = determineFitnessLevel(profile);
    final volume = getVolumeAdjustment(age);
    final sexAdj = getSexAdjustment(sex);

    final baseSets = volume['sets']!;
    final baseReps = volume['reps']!;
    final baseRest = volume['rest']!;

    // Más ejercicios de glúteos para mujeres
    final glutesFocus = sexAdj['focusLower'] > 0.5;

    return Routine(
      id: _uuid.v4(),
      name: 'Mi Rutina - Tren Inferior',
      description: 'Piernas, glúteos y core personalizados.',
      createdAt: DateTime.now(),
      exercises: [
        // Piernas
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'legs_001',
          sets: baseSets,
          reps: baseReps + 3,
          restSeconds: baseRest + 15,
          notes: 'Sentadillas - ejercicio base',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: level == 'principiante' ? 'legs_004' : 'legs_002',
          sets: baseSets,
          reps: baseReps,
          restSeconds: baseRest + 15,
          notes: 'Trabajo unilateral',
        ),
        if (level != 'principiante')
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_008',
            sets: baseSets - 1,
            reps: baseReps - 2,
            restSeconds: baseRest + 15,
            notes: 'Explosividad',
          ),
        // Glúteos (más énfasis si es mujer)
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'glutes_001',
          sets: glutesFocus ? baseSets + 1 : baseSets,
          reps: baseReps + 3,
          restSeconds: baseRest,
          notes: 'Puente de glúteos',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'glutes_003',
          sets: glutesFocus ? baseSets : baseSets - 1,
          reps: baseReps + 2,
          restSeconds: baseRest,
          notes: 'Hip thrust',
        ),
        if (glutesFocus)
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'glutes_005',
            sets: baseSets - 1,
            reps: baseReps,
            restSeconds: baseRest,
            notes: 'Trabajo adicional de glúteos',
          ),
        // Pantorrillas
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'calves_001',
          sets: baseSets - 1,
          reps: baseReps + 5,
          restSeconds: baseRest - 30,
          notes: 'Elevación de talones',
        ),
        // Core
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'core_001',
          sets: baseSets - 1,
          reps: (baseReps * 3).clamp(20, 60),
          restSeconds: baseRest - 15,
          notes: 'Plancha',
        ),
        RoutineExercise(
          id: _uuid.v4(),
          exerciseId: 'core_007',
          sets: baseSets - 1,
          reps: baseReps + 5,
          restSeconds: baseRest - 15,
          notes: 'Bicicleta abdominal',
        ),
      ],
    );
  }

  // Obtener todas las rutinas personalizadas
  static List<Routine> generatePersonalizedRoutines(UserProfile profile) {
    return [
      generateFullBodyRoutine(profile),
      generateUpperBodyRoutine(profile),
      generateLowerBodyRoutine(profile),
      generateCardioRoutine(profile),
    ];
  }

  // Obtener recomendación de frecuencia semanal
  static Map<String, dynamic> getWeeklyRecommendation(UserProfile profile) {
    final age = profile.age ?? 25;
    final level = determineFitnessLevel(profile);
    final bmi = calculateBMI(profile.weight ?? 70, profile.height ?? 170);

    int daysPerWeek = 3;
    String split = 'Cuerpo completo';
    String cardioRecommendation = '2-3 sesiones de 20-30 min';

    if (level == 'intermedio') {
      daysPerWeek = 4;
      split = 'Upper/Lower (2x por semana)';
      cardioRecommendation = '3 sesiones de 25-35 min';
    } else if (level == 'avanzado') {
      daysPerWeek = 5;
      split = 'Push/Pull/Legs';
      cardioRecommendation = '3-4 sesiones de 30-40 min';
    }

    if (age > 50) {
      daysPerWeek = daysPerWeek > 3 ? 3 : daysPerWeek;
    }

    if (bmi > 30) {
      cardioRecommendation = '4-5 sesiones de baja intensidad 30-45 min';
    }

    return {
      'daysPerWeek': daysPerWeek,
      'split': split,
      'cardioRecommendation': cardioRecommendation,
      'restDays': 7 - daysPerWeek,
      'level': level,
    };
  }
}
