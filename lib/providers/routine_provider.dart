import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/models/routine_log.dart';

class RoutineProvider with ChangeNotifier {
  final Box<Routine> _routineBox = Hive.box<Routine>('routines');
  final Box<RoutineLog> _routineLogBox = Hive.box<RoutineLog>('routine_logs');
  final Box<RoutineExercise> _routineExerciseBox = Hive.box<RoutineExercise>('routine_exercises');
  final Box<Exercise> _exerciseBox = Hive.box<Exercise>('exercises');

  // Helper method to load associated exercises into RoutineExercise objects
  void _loadExercisesForRoutine(Routine routine) {
    if (routine.exercises == null) return;
    for (var routineExercise in routine.exercises!) {
      final exercise = _exerciseBox.get(routineExercise.exerciseId);
      if (exercise != null) {
        // This is the crucial step that was missing
        routineExercise.setExercise(exercise);
      } else {
        // Handle the case where an exercise ID is invalid, perhaps log it
        // or create a placeholder 'Error' exercise object.
      }
    }
  }

  List<Routine> get routines {
    final routineList = _routineBox.values.toList();
    // Before returning the routines, ensure their exercises are fully loaded.
    for (var routine in routineList) {
      _loadExercisesForRoutine(routine);
    }
    return routineList;
  }

  List<RoutineLog> get routineLogs => _routineLogBox.values.toList();

  // ****** Routine Methods ******

  Future<Routine> addRoutine(String name, String description) async {
    final routine = Routine(
      id: DateTime.now().toString(), // Using a simpler unique ID
      name: name,
      description: description,
    );
    await _routineBox.put(routine.id, routine);
    routine.exercises = HiveList(_routineExerciseBox);
    await routine.save(); 
    
    // Even though it's new, we call this for consistency.
    _loadExercisesForRoutine(routine);

    notifyListeners();
    return routine;
  }

  Future<void> updateRoutine(Routine routine, List<RoutineExercise> updatedExercises) async {
    final HiveList<RoutineExercise> hiveList = routine.exercises!;

    final List<RoutineExercise> toDelete = [];
    for (var existingExercise in hiveList) {
      if (!updatedExercises.any((element) => element.key == existingExercise.key)) {
        toDelete.add(existingExercise);
      }
    }

    for (var exercise in toDelete) {
      await exercise.delete();
    }

    for (var updatedExercise in updatedExercises) {
      if (!updatedExercise.isInBox) {
        await _routineExerciseBox.add(updatedExercise);
        hiveList.add(updatedExercise);
      } else {
        await updatedExercise.save();
      }
    }

    await routine.save();

    // After saving, reload the exercise data to ensure the UI has full objects.
    _loadExercisesForRoutine(routine);
    
    notifyListeners();
  }

  Future<void> deleteRoutine(String id) async {
    final routine = _routineBox.get(id);
    if (routine != null && routine.exercises != null) {
      final exercisesToDelete = routine.exercises!.toList();
      for (var ex in exercisesToDelete) {
         await ex.delete();
      }
    }
    await _routineBox.delete(id);
    notifyListeners();
  }

  // ****** RoutineLog Methods ******

  Future<void> addRoutineLog(RoutineLog routineLog) async {
    await _routineLogBox.add(routineLog);
    notifyListeners();
  }

  List<RoutineLog> getRoutineLogsByDate(DateTime date) {
    return _routineLogBox.values
        .where((log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day)
        .toList();
  }
}
