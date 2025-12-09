import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:uuid/uuid.dart';

class DefaultRoutines {
  static const _uuid = Uuid();

  // Rutina para Principiantes - Cuerpo Completo
  static Routine get beginnerFullBody => Routine(
        id: _uuid.v4(),
        name: 'Principiante - Cuerpo Completo',
        description: 'Rutina básica para comenzar tu camino fitness. 3 días por semana.',
        createdAt: DateTime.now(),
        exercises: [
          // Pecho
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'chest_001', // Flexiones estándar
            sets: 3,
            reps: 8,
            restSeconds: 90,
            notes: 'Si no puedes hacer 8, haz flexiones de rodillas',
          ),
          // Piernas
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_001', // Sentadillas
            sets: 3,
            reps: 12,
            restSeconds: 90,
            notes: 'Mantén la espalda recta',
          ),
          // Espalda
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'back_001', // Dominadas australianas
            sets: 3,
            reps: 8,
            restSeconds: 90,
            notes: 'Usa una mesa resistente',
          ),
          // Hombros
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'shoulders_001', // Pike push-ups
            sets: 3,
            reps: 8,
            restSeconds: 60,
            notes: 'Forma de V invertida',
          ),
          // Core
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'core_001', // Planchas
            sets: 3,
            reps: 30,
            restSeconds: 60,
            notes: 'Mantén el cuerpo recto como tabla',
          ),
        ],
      );

  // Rutina Intermedia - Upper/Lower Split
  static Routine get intermediateUpper => Routine(
        id: _uuid.v4(),
        name: 'Intermedio - Tren Superior',
        description: 'Enfoque en pecho, espalda, hombros y brazos. Día 1 de 2.',
        createdAt: DateTime.now(),
        exercises: [
          // Pecho
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'chest_003', // Flexiones declinadas
            sets: 4,
            reps: 12,
            restSeconds: 75,
            notes: 'Pies elevados en silla',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'chest_005', // Flexiones diamante
            sets: 3,
            reps: 10,
            restSeconds: 75,
            notes: 'Manos juntas formando diamante',
          ),
          // Espalda
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'back_001', // Dominadas australianas
            sets: 4,
            reps: 12,
            restSeconds: 75,
            notes: 'Pies más adelante para mayor dificultad',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'back_005', // Superman
            sets: 3,
            reps: 15,
            restSeconds: 60,
            notes: 'Contrae la espalda baja',
          ),
          // Hombros
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'shoulders_001', // Pike push-ups
            sets: 4,
            reps: 12,
            restSeconds: 75,
            notes: 'Máxima elevación de cadera',
          ),
          // Bíceps
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'biceps_001', // Curl con mochila
            sets: 3,
            reps: 12,
            restSeconds: 60,
            notes: 'Usa peso moderado',
          ),
          // Tríceps
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'triceps_001', // Fondos en silla
            sets: 3,
            reps: 12,
            restSeconds: 60,
            notes: 'Baja hasta 90 grados',
          ),
        ],
      );

  static Routine get intermediateLower => Routine(
        id: _uuid.v4(),
        name: 'Intermedio - Tren Inferior',
        description: 'Enfoque en piernas, glúteos y core. Día 2 de 2.',
        createdAt: DateTime.now(),
        exercises: [
          // Piernas
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_001', // Sentadillas
            sets: 4,
            reps: 15,
            restSeconds: 90,
            notes: 'Usa mochila con peso si es necesario',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_002', // Sentadilla búlgara
            sets: 3,
            reps: 12,
            restSeconds: 90,
            notes: '12 por pierna',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_004', // Zancadas
            sets: 3,
            reps: 12,
            restSeconds: 75,
            notes: '12 por pierna, alterna',
          ),
          // Glúteos
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'glutes_001', // Puente de glúteos
            sets: 4,
            reps: 15,
            restSeconds: 60,
            notes: 'Contrae arriba 2 segundos',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'glutes_003', // Hip Thrust
            sets: 3,
            reps: 15,
            restSeconds: 75,
            notes: 'Espalda en silla/sofá',
          ),
          // Pantorrillas
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'calves_001', // Elevación de talones
            sets: 4,
            reps: 20,
            restSeconds: 45,
            notes: 'Pausa arriba',
          ),
          // Core
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'core_002', // Crunch abdominal
            sets: 3,
            reps: 20,
            restSeconds: 45,
            notes: 'No jales el cuello',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'core_007', // Bicicleta
            sets: 3,
            reps: 20,
            restSeconds: 45,
            notes: '20 por lado',
          ),
        ],
      );

  // Rutina Avanzada - Push/Pull/Legs
  static Routine get advancedPush => Routine(
        id: _uuid.v4(),
        name: 'Avanzado - Push (Empuje)',
        description: 'Pecho, hombros y tríceps. Alta intensidad. Día 1 de 3.',
        createdAt: DateTime.now(),
        exercises: [
          // Pecho
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'chest_003', // Flexiones declinadas
            sets: 5,
            reps: 15,
            restSeconds: 60,
            notes: 'Pies elevados máximo posible',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'chest_005', // Flexiones diamante
            sets: 4,
            reps: 12,
            restSeconds: 60,
            notes: 'Tempo lento',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'chest_007', // Flexiones arqueras
            sets: 4,
            reps: 10,
            restSeconds: 75,
            notes: '10 por lado',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'chest_009', // Flexiones explosivas
            sets: 3,
            reps: 8,
            restSeconds: 90,
            notes: 'Máxima explosividad',
          ),
          // Hombros
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'shoulders_001', // Pike push-ups
            sets: 4,
            reps: 15,
            restSeconds: 75,
            notes: 'Cadera alta',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'shoulders_004', // Flexiones en pino asistidas
            sets: 3,
            reps: 8,
            restSeconds: 120,
            notes: 'Pared como apoyo',
          ),
          // Tríceps
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'triceps_001', // Fondos en silla
            sets: 4,
            reps: 15,
            restSeconds: 60,
            notes: 'Piernas extendidas para más dificultad',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'triceps_003', // Flexiones cerradas
            sets: 3,
            reps: 12,
            restSeconds: 60,
            notes: 'Codos pegados al cuerpo',
          ),
        ],
      );

  static Routine get advancedPull => Routine(
        id: _uuid.v4(),
        name: 'Avanzado - Pull (Jalón)',
        description: 'Espalda, bíceps y antebrazos. Alta intensidad. Día 2 de 3.',
        createdAt: DateTime.now(),
        exercises: [
          // Espalda
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'back_001', // Dominadas australianas
            sets: 5,
            reps: 15,
            restSeconds: 75,
            notes: 'Pies lo más adelante posible',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'back_005', // Superman
            sets: 4,
            reps: 20,
            restSeconds: 60,
            notes: 'Sostén arriba 3 segundos',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'back_008', // Remo con toalla
            sets: 4,
            reps: 12,
            restSeconds: 75,
            notes: 'Contracción máxima',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'back_010', // Pull-ups en puerta
            sets: 4,
            reps: 8,
            restSeconds: 90,
            notes: 'Usa toalla en marco de puerta',
          ),
          // Bíceps
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'biceps_001', // Curl con mochila
            sets: 4,
            reps: 15,
            restSeconds: 60,
            notes: 'Máximo peso posible',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'biceps_002', // Curl isométrico
            sets: 3,
            reps: 30,
            restSeconds: 75,
            notes: 'Sostén 90 grados',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'biceps_005', // Chin-up hold
            sets: 3,
            reps: 20,
            restSeconds: 90,
            notes: 'Isométrico en barra',
          ),
          // Antebrazos
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'forearms_001', // Curl de muñeca
            sets: 3,
            reps: 20,
            restSeconds: 45,
            notes: 'Rango completo de movimiento',
          ),
        ],
      );

  static Routine get advancedLegs => Routine(
        id: _uuid.v4(),
        name: 'Avanzado - Legs (Piernas)',
        description: 'Piernas, glúteos y core. Alta intensidad. Día 3 de 3.',
        createdAt: DateTime.now(),
        exercises: [
          // Piernas
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_001', // Sentadillas
            sets: 5,
            reps: 20,
            restSeconds: 90,
            notes: 'Máximo peso en mochila',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_002', // Sentadilla búlgara
            sets: 4,
            reps: 15,
            restSeconds: 90,
            notes: '15 por pierna',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_003', // Sentadilla pistol asistida
            sets: 4,
            reps: 8,
            restSeconds: 90,
            notes: '8 por pierna',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_004', // Zancadas
            sets: 4,
            reps: 15,
            restSeconds: 75,
            notes: '15 por pierna',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_008', // Saltos explosivos
            sets: 4,
            reps: 12,
            restSeconds: 90,
            notes: 'Máxima explosividad',
          ),
          // Glúteos
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'glutes_003', // Hip Thrust
            sets: 5,
            reps: 20,
            restSeconds: 75,
            notes: 'Con peso en cadera',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'glutes_001', // Puente de glúteos
            sets: 4,
            reps: 20,
            restSeconds: 60,
            notes: 'Una pierna elevada',
          ),
          // Pantorrillas
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'calves_001', // Elevación de talones
            sets: 5,
            reps: 25,
            restSeconds: 45,
            notes: 'Una pierna si es posible',
          ),
          // Core
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'core_001', // Planchas
            sets: 3,
            reps: 60,
            restSeconds: 60,
            notes: 'Mantén 60 segundos',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'core_003', // Plancha lateral
            sets: 3,
            reps: 45,
            restSeconds: 60,
            notes: '45 seg por lado',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'core_009', // Russian twists
            sets: 3,
            reps: 30,
            restSeconds: 45,
            notes: '30 por lado con peso',
          ),
        ],
      );

  // Rutina de Cardio - Todas las dificultades
  static Routine get cardioHIIT => Routine(
        id: _uuid.v4(),
        name: 'Cardio HIIT - Quema Grasa',
        description: 'Entrenamiento de alta intensidad. Ajusta según tu nivel.',
        createdAt: DateTime.now(),
        exercises: [
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'cardio_001', // Jumping jacks
            sets: 3,
            reps: 30,
            restSeconds: 30,
            notes: 'Principiante: 20, Intermedio: 30, Avanzado: 40',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'cardio_002', // Burpees
            sets: 3,
            reps: 10,
            restSeconds: 60,
            notes: 'Principiante: 6, Intermedio: 10, Avanzado: 15',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'cardio_003', // Mountain climbers
            sets: 3,
            reps: 30,
            restSeconds: 45,
            notes: '30 por pierna',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'cardio_004', // High knees
            sets: 3,
            reps: 30,
            restSeconds: 45,
            notes: 'Rodillas lo más alto posible',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'cardio_006', // Skaters
            sets: 3,
            reps: 20,
            restSeconds: 45,
            notes: '20 por lado',
          ),
          RoutineExercise(
            id: _uuid.v4(),
            exerciseId: 'legs_008', // Saltos explosivos
            sets: 3,
            reps: 15,
            restSeconds: 60,
            notes: 'Máxima altura',
          ),
        ],
      );

  // Lista de todas las rutinas predefinidas
  static List<Routine> get all => [
        beginnerFullBody,
        intermediateUpper,
        intermediateLower,
        advancedPush,
        advancedPull,
        advancedLegs,
        cardioHIIT,
      ];

  static List<Routine> getByDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return [beginnerFullBody, cardioHIIT];
      case 'intermedio':
        return [intermediateUpper, intermediateLower, cardioHIIT];
      case 'avanzado':
        return [advancedPush, advancedPull, advancedLegs, cardioHIIT];
      default:
        return all;
    }
  }
}
