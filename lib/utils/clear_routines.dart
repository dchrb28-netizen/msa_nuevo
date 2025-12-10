import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/routine.dart';

/// Utilidad para limpiar rutinas predeterminadas que se crearon automáticamente
class ClearRoutines {
  /// Elimina todas las rutinas que fueron creadas automáticamente
  /// Identifica rutinas predeterminadas por sus nombres conocidos
  static Future<void> clearDefaultRoutines() async {
    final routineBox = Hive.box<Routine>('routines');
    
    final defaultRoutineNames = [
      'Full Body Principiante',
      'Upper/Lower Split',
      'Push/Pull/Legs',
      'Core Strength',
      'HIIT Cardio',
      'Yoga & Flexibilidad',
      'Workout en Casa',
      'Fuerza Total',
    ];

    final routinesToDelete = <dynamic>[];
    
    // Buscar rutinas predeterminadas
    for (var i = 0; i < routineBox.length; i++) {
      final routine = routineBox.getAt(i);
      if (routine != null && defaultRoutineNames.contains(routine.name)) {
        routinesToDelete.add(routine.key);
      }
    }

    // Eliminar rutinas encontradas
    for (var key in routinesToDelete) {
      await routineBox.delete(key);
    }

    print('✅ Eliminadas ${routinesToDelete.length} rutinas predeterminadas');
  }

  /// Limpia TODAS las rutinas (usar con precaución)
  static Future<void> clearAllRoutines() async {
    final routineBox = Hive.box<Routine>('routines');
    await routineBox.clear();
    print('✅ Todas las rutinas eliminadas');
  }

  /// Muestra lista de todas las rutinas actuales
  static void listAllRoutines() {
    final routineBox = Hive.box<Routine>('routines');
    print('📋 Rutinas actuales (${routineBox.length}):');
    for (var i = 0; i < routineBox.length; i++) {
      final routine = routineBox.getAt(i);
      print('  $i. ${routine?.name} (${routine?.exercises?.length ?? 0} ejercicios)');
    }
  }
}
