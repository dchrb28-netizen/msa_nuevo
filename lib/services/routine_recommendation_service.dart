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
    
    // Lógica mejorada
    if (age < 30 && bmi >= 18.5 && bmi <= 24.9) {
      return 'intermedio';
    } else if (age >= 55 || bmi < 18.5 || bmi > 32) {
      return 'principiante';
    } else if (age >= 45 && age < 55 && (bmi < 20 || bmi > 28)) {
      return 'principiante';
    } else if (age < 45 && bmi >= 18.5 && bmi <= 28) {
      return 'intermedio';
    } else if (age < 35 && bmi >= 20 && bmi <= 26) {
      return 'avanzado';
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
    final level = determineFitnessLevel(user);
    final isMale = user.gender.toLowerCase().contains('masculino') || 
                   user.gender.toLowerCase().contains('hombre') ||
                   user.gender.toLowerCase().contains('male');
    
    // Ajustar sets y reps según edad y nivel
    int baseSets = level == 'avanzado' ? 4 : level == 'intermedio' ? 3 : 3;
    if (age >= 50) baseSets = baseSets > 3 ? 3 : baseSets;
    
    String baseReps = age < 35 ? '10-12' : age < 50 ? '8-10' : '8-10';
    int baseRest = age < 35 ? 60 : age < 50 ? 75 : 90;
    
    List<ExerciseTemplate> exercises = [];
    
    // Personalización según género y objetivos
    if (isMale) {
      // Hombres: Mayor énfasis en tren superior y fuerza
      if (level == 'principiante') {
        exercises = [
          ExerciseTemplate(exerciseId: 'crd_001', sets: 2, reps: '30', restTime: 30), // Jumping jacks
          ExerciseTemplate(exerciseId: 'chest_001', sets: baseSets, reps: baseReps, restTime: baseRest),
          ExerciseTemplate(exerciseId: 'back_013', sets: baseSets, reps: '10', restTime: baseRest), // Remo invertido
          ExerciseTemplate(exerciseId: 'legs_001', sets: baseSets, reps: '12-15', restTime: baseRest + 15),
          ExerciseTemplate(exerciseId: 'legs_013', sets: baseSets, reps: '15', restTime: baseRest), // Hip thrust
          ExerciseTemplate(exerciseId: 'shld_001', sets: baseSets - 1, reps: baseReps, restTime: baseRest),
          ExerciseTemplate(exerciseId: 'arms_012', sets: baseSets - 1, reps: '12', restTime: baseRest - 15), // Curl toalla
          ExerciseTemplate(exerciseId: 'abs_001', sets: 3, reps: '15', restTime: 45),
        ];
      } else if (level == 'intermedio') {
        exercises = [
          ExerciseTemplate(exerciseId: 'crd_006', sets: 2, reps: '30s', restTime: 30), // Mountain climbers
          ExerciseTemplate(exerciseId: 'chest_001', sets: baseSets + 1, reps: '12', restTime: baseRest),
          ExerciseTemplate(exerciseId: 'chest_004', sets: 3, reps: '10', restTime: baseRest), // Diamante
          ExerciseTemplate(exerciseId: 'back_013', sets: baseSets, reps: '12', restTime: baseRest), // Remo invertido
          ExerciseTemplate(exerciseId: 'back_012', sets: 3, reps: '15', restTime: baseRest - 15), // Face pulls
          ExerciseTemplate(exerciseId: 'legs_001', sets: baseSets, reps: '15', restTime: baseRest + 15),
          ExerciseTemplate(exerciseId: 'legs_012', sets: 3, reps: '12', restTime: baseRest), // Búlgaras
          ExerciseTemplate(exerciseId: 'shld_002', sets: 3, reps: '10', restTime: baseRest), // Pike
          ExerciseTemplate(exerciseId: 'arms_013', sets: 3, reps: '8', restTime: baseRest), // Chin-ups
          ExerciseTemplate(exerciseId: 'abs_013', sets: 3, reps: '30s', restTime: 45), // Hollow hold
          ExerciseTemplate(exerciseId: 'abs_006', sets: 3, reps: '15', restTime: 30),
        ];
      } else { // Avanzado
        exercises = [
          ExerciseTemplate(exerciseId: 'crd_008', sets: 1, reps: '3min', restTime: 60), // Shadow boxing
          ExerciseTemplate(exerciseId: 'chest_012', sets: 4, reps: '8', restTime: 90), // Archer
          ExerciseTemplate(exerciseId: 'chest_013', sets: 3, reps: '6', restTime: 90), // Pseudo planche
          ExerciseTemplate(exerciseId: 'back_001', sets: 4, reps: '10', restTime: 90), // Dominadas
          ExerciseTemplate(exerciseId: 'shld_004', sets: 3, reps: '5', restTime: 120), // Handstand
          ExerciseTemplate(exerciseId: 'legs_014', sets: 3, reps: '8', restTime: 90), // Pistol squat
          ExerciseTemplate(exerciseId: 'legs_012', sets: 4, reps: '12', restTime: baseRest), // Búlgaras
          ExerciseTemplate(exerciseId: 'abs_012', sets: 3, reps: '5', restTime: 90), // Dragon flag
          ExerciseTemplate(exerciseId: 'abs_013', sets: 3, reps: '45s', restTime: 60), // Hollow hold
          ExerciseTemplate(exerciseId: 'fullbody_002', sets: 3, reps: '8', restTime: 90), // Man maker
        ];
      }
    } else {
      // Mujeres: Mayor énfasis en tren inferior, glúteos y core
      if (level == 'principiante') {
        exercises = [
          ExerciseTemplate(exerciseId: 'crd_001', sets: 2, reps: '30', restTime: 30), // Jumping jacks
          ExerciseTemplate(exerciseId: 'legs_001', sets: baseSets + 1, reps: '12-15', restTime: baseRest + 15),
          ExerciseTemplate(exerciseId: 'legs_013', sets: baseSets, reps: '15', restTime: baseRest), // Hip thrust
          ExerciseTemplate(exerciseId: 'legs_004', sets: baseSets, reps: '12', restTime: baseRest), // Zancadas
          ExerciseTemplate(exerciseId: 'chest_002', sets: baseSets - 1, reps: '10', restTime: baseRest), // Inclinadas
          ExerciseTemplate(exerciseId: 'back_013', sets: baseSets - 1, reps: '10', restTime: baseRest), // Remo invertido
          ExerciseTemplate(exerciseId: 'abs_001', sets: 3, reps: '15', restTime: 45),
          ExerciseTemplate(exerciseId: 'abs_002', sets: 3, reps: '45s', restTime: 30), // Plancha
        ];
      } else if (level == 'intermedio') {
        exercises = [
          ExerciseTemplate(exerciseId: 'crd_006', sets: 2, reps: '30s', restTime: 30), // Mountain climbers
          ExerciseTemplate(exerciseId: 'legs_001', sets: baseSets + 1, reps: '15', restTime: baseRest + 15),
          ExerciseTemplate(exerciseId: 'legs_012', sets: baseSets, reps: '12', restTime: baseRest), // Búlgaras
          ExerciseTemplate(exerciseId: 'legs_013', sets: baseSets, reps: '15', restTime: baseRest), // Hip thrust
          ExerciseTemplate(exerciseId: 'legs_004', sets: baseSets, reps: '15', restTime: baseRest), // Zancadas
          ExerciseTemplate(exerciseId: 'chest_001', sets: 3, reps: '12', restTime: baseRest),
          ExerciseTemplate(exerciseId: 'back_013', sets: 3, reps: '12', restTime: baseRest), // Remo invertido
          ExerciseTemplate(exerciseId: 'shld_001', sets: 3, reps: '12', restTime: baseRest),
          ExerciseTemplate(exerciseId: 'abs_013', sets: 3, reps: '30s', restTime: 45), // Hollow hold
          ExerciseTemplate(exerciseId: 'abs_006', sets: 3, reps: '15', restTime: 30), // Bicicleta
          ExerciseTemplate(exerciseId: 'abs_002', sets: 2, reps: '60s', restTime: 30), // Plancha
        ];
      } else { // Avanzado
        exercises = [
          ExerciseTemplate(exerciseId: 'crd_008', sets: 1, reps: '3min', restTime: 60), // Shadow boxing
          ExerciseTemplate(exerciseId: 'legs_014', sets: 4, reps: '8', restTime: 90), // Pistol squat
          ExerciseTemplate(exerciseId: 'legs_012', sets: 4, reps: '15', restTime: baseRest), // Búlgaras
          ExerciseTemplate(exerciseId: 'legs_013', sets: 4, reps: '20', restTime: baseRest), // Hip thrust
          ExerciseTemplate(exerciseId: 'chest_012', sets: 3, reps: '8', restTime: baseRest), // Archer
          ExerciseTemplate(exerciseId: 'back_001', sets: 4, reps: '8', restTime: 90), // Dominadas
          ExerciseTemplate(exerciseId: 'shld_002', sets: 3, reps: '12', restTime: baseRest), // Pike
          ExerciseTemplate(exerciseId: 'abs_012', sets: 3, reps: '5', restTime: 90), // Dragon flag
          ExerciseTemplate(exerciseId: 'abs_013', sets: 3, reps: '60s', restTime: 60), // Hollow hold
          ExerciseTemplate(exerciseId: 'fullbody_001', sets: 3, reps: '6', restTime: 90), // Turkish get-up
        ];
      }
    }
    
    // Agregar cardio extra si hay sobrepeso/obesidad
    if (bmi > 27) {
      exercises.insert(0, ExerciseTemplate(
        exerciseId: 'crd_001',
        sets: 1,
        reps: age >= 50 ? '10min' : '15min',
        restTime: 0,
      ));
    }
    
    final bmiCategory = bmi < 18.5 ? 'bajo peso' : 
                       bmi < 25 ? 'peso normal' : 
                       bmi < 30 ? 'sobrepeso' : 'obesidad';
    
    final genderText = isMale ? 'Hombre' : 'Mujer';
    
    return RoutineTemplate(
      name: '⭐ Mi Rutina Personalizada',
      description: '$genderText, $age años, ${user.height.toStringAsFixed(0)}cm, ${user.weight.toStringAsFixed(1)}kg\n'
                  'IMC: ${bmi.toStringAsFixed(1)} ($bmiCategory) • Nivel: ${level.toUpperCase()}',
      level: level,
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
