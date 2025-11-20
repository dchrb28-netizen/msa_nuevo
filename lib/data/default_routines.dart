import 'package:hive/hive.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';

void createDefaultRoutines() {
  final routineBox = Hive.box<Routine>('routines');

  // Only create default routines if the box is empty
  if (routineBox.isEmpty) {
    final routineExerciseBox = Hive.box<RoutineExercise>('routine_exercises');

    // It's a good practice to also ensure the related box is clear
    // if we are setting up defaults from a clean slate.
    routineExerciseBox.clear();

    // If you have default routines to add, add them here.
    // For example:
    /*
    final defaultRoutine = Routine(
      id: 'default-1',
      name: 'Rutina de Inicio Rápido',
      description: 'Una rutina básica para empezar.',
    );
    routineBox.put(defaultRoutine.id, defaultRoutine);
    */
  }
}
