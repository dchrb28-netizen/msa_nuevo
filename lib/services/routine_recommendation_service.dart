import 'package:myapp/data/routine_templates.dart';
import 'package:myapp/models/user.dart';

class RoutineRecommendationService {
  // Calcular IMC
  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  // Determinar nivel de condición física basado en edad e IMC
  static String determineFitnessLevel(User user) {
    final age = user.age;
    final bmi = calculateBMI(user.weight, user.height);
    
    // Lógica simplificada
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

  // Obtener recomendación de rutinas según el usuario
  static List<RoutineTemplate> getRecommendedRoutines(User user) {
    final level = determineFitnessLevel(user);
    final bmi = calculateBMI(user.weight, user.height);
    
    List<RoutineTemplate> recommended = [];
    
    // Siempre incluir cardio si hay sobrepeso
    if (bmi > 25) {
      recommended.add(RoutineTemplates.cardioHIIT);
    }
    
    // Agregar rutinas según nivel
    if (level == 'principiante') {
      recommended.add(RoutineTemplates.beginnerFullBody);
      if (bmi <= 25) {
        recommended.add(RoutineTemplates.cardioHIIT);
      }
    } else if (level == 'intermedio') {
      recommended.add(RoutineTemplates.intermediateUpper);
      recommended.add(RoutineTemplates.intermediateLower);
      if (!recommended.contains(RoutineTemplates.cardioHIIT)) {
        recommended.add(RoutineTemplates.cardioHIIT);
      }
    } else {
      // Avanzado
      recommended.add(RoutineTemplates.advancedPush);
      recommended.add(RoutineTemplates.advancedPull);
      recommended.add(RoutineTemplates.advancedLegs);
      if (!recommended.contains(RoutineTemplates.cardioHIIT)) {
        recommended.add(RoutineTemplates.cardioHIIT);
      }
    }
    
    return recommended;
  }

  // Generar una rutina personalizada ajustada al usuario
  static RoutineTemplate generatePersonalizedRoutine(User user) {
    final age = user.age;
    final bmi = calculateBMI(user.weight, user.height);
    final isMale = user.gender.toLowerCase().contains('masculino') || 
                   user.gender.toLowerCase().contains('hombre');
    
    // Ajustar sets y reps según edad
    int baseSets = age < 25 ? 4 : age < 40 ? 4 : age < 55 ? 3 : 3;
    String baseReps = age < 40 ? '10-12' : '8-10';
    int baseRest = age < 40 ? 75 : age < 55 ? 90 : 120;
    
    List<ExerciseTemplate> exercises = [];
    
    if (isMale) {
      // Mayor énfasis en tren superior
      exercises = [
        ExerciseTemplate(
          exerciseId: 'chest_001',
          sets: baseSets,
          reps: baseReps,
          restTime: baseRest,
        ),
        ExerciseTemplate(
          exerciseId: 'back_001',
          sets: baseSets,
          reps: baseReps,
          restTime: baseRest,
        ),
        ExerciseTemplate(
          exerciseId: 'shoulders_001',
          sets: baseSets - 1,
          reps: baseReps,
          restTime: baseRest - 15,
        ),
        ExerciseTemplate(
          exerciseId: 'legs_001',
          sets: baseSets,
          reps: '12-15',
          restTime: baseRest + 15,
        ),
        ExerciseTemplate(
          exerciseId: 'triceps_001',
          sets: baseSets - 1,
          reps: baseReps,
          restTime: baseRest - 15,
        ),
        ExerciseTemplate(
          exerciseId: 'core_001',
          sets: baseSets - 1,
          reps: '30-45 seg',
          restTime: baseRest - 15,
        ),
      ];
    } else {
      // Mayor énfasis en tren inferior y glúteos
      exercises = [
        ExerciseTemplate(
          exerciseId: 'legs_001',
          sets: baseSets,
          reps: '12-15',
          restTime: baseRest + 15,
        ),
        ExerciseTemplate(
          exerciseId: 'legs_004',
          sets: baseSets,
          reps: baseReps,
          restTime: baseRest + 15,
        ),
        ExerciseTemplate(
          exerciseId: 'glutes_001',
          sets: baseSets,
          reps: '12-15',
          restTime: baseRest,
        ),
        ExerciseTemplate(
          exerciseId: 'glutes_003',
          sets: baseSets,
          reps: '12-15',
          restTime: baseRest,
        ),
        ExerciseTemplate(
          exerciseId: 'chest_001',
          sets: baseSets - 1,
          reps: baseReps,
          restTime: baseRest,
        ),
        ExerciseTemplate(
          exerciseId: 'back_001',
          sets: baseSets - 1,
          reps: baseReps,
          restTime: baseRest,
        ),
        ExerciseTemplate(
          exerciseId: 'core_001',
          sets: baseSets,
          reps: '30-45 seg',
          restTime: baseRest - 15,
        ),
      ];
    }
    
    final bmiCategory = bmi < 18.5 ? 'bajo peso' : 
                       bmi < 25 ? 'peso normal' : 
                       bmi < 30 ? 'sobrepeso' : 'obesidad';
    
    return RoutineTemplate(
      name: 'Mi Rutina Personalizada',
      description: 'Adaptada a: ${user.gender}, $age años, IMC ${bmi.toStringAsFixed(1)} ($bmiCategory)',
      level: determineFitnessLevel(user),
      exercises: exercises,
    );
  }

  // Obtener recomendación de frecuencia semanal
  static Map<String, dynamic> getWeeklyRecommendation(User user) {
    final age = user.age;
    final level = determineFitnessLevel(user);
    final bmi = calculateBMI(user.weight, user.height);

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

    if (age >= 50) {
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
      'bmi': bmi,
    };
  }
}
