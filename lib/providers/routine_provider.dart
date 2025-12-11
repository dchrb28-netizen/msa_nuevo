import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/models/routine_log.dart';

class RoutineProvider with ChangeNotifier {
    /// Guarda una rutina completa (nombre, descripción, días, ejercicios) en una sola operación atómica.
    Future<Routine> createFullRoutine({
      required String name,
      required String description,
      required List<String> daysOfWeek,
      required List<RoutineExercise> exercises,
    }) async {
      final routine = Routine(
        id: DateTime.now().toString(),
        name: name,
        description: description,
        dayOfWeek: daysOfWeek.isNotEmpty ? daysOfWeek.first : null,
      );
      routine.daysOfWeek = daysOfWeek.isNotEmpty ? daysOfWeek : null;
      // Guardar ejercicios en Hive y asociar a la rutina
      final HiveList<RoutineExercise> hiveList = HiveList(_routineExerciseBox);
      for (final ex in exercises) {
        if (!ex.isInBox) {
          await _routineExerciseBox.add(ex);
        }
        hiveList.add(ex);
        await ex.save();
      }
      routine.exercises = hiveList;
      debugPrint('[RoutineProvider] createFullRoutine: saving routine ${routine.name} id=${routine.id} with ${hiveList.length} exercises');
      await _routineBox.put(routine.id, routine);
      await routine.save();
      _loadExercisesForRoutine(routine);
      debugPrint('[RoutineProvider] createFullRoutine: saved routine ${routine.name}');
      notifyListeners();
      // Log current routines count for debugging save issues
      try {
        debugPrint('[RoutineProvider] createFullRoutine: total routines in box=${_routineBox.length}');
      } catch (e) {
        debugPrint('[RoutineProvider] createFullRoutine: error reading routines count: $e');
      }
      return routine;
    }
  final Box<Routine> _routineBox = Hive.box<Routine>('routines');
  final Box<RoutineLog> _routineLogBox = Hive.box<RoutineLog>('routine_logs');
  final Box<RoutineExercise> _routineExerciseBox = Hive.box<RoutineExercise>(
    'routine_exercises',
  );
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

  Routine? getRoutineForDay(String dayOfWeek) {
    try {
      // Buscar rutinas que tengan el día en activeDays (soporta dayOfWeek y daysOfWeek)
      final routine = routines.firstWhere(
        (r) => r.activeDays.any((d) => d.toLowerCase() == dayOfWeek.toLowerCase()),
      );
      _loadExercisesForRoutine(routine);
      return routine;
    } catch (e) {
      return null;
    }
  }

  List<RoutineLog> get routineLogs => _routineLogBox.values.toList();

  // ****** Routine Methods ******

  Future<Routine> addRoutine(
    String name,
    String description,
    String? dayOfWeek,
  ) async {
    final routine = Routine(
      id: DateTime.now().toString(),
      name: name,
      description: description,
      dayOfWeek: dayOfWeek,
    );
    // Inicializar la HiveList vacía antes de guardar
    routine.exercises = HiveList(_routineExerciseBox);
    debugPrint('[RoutineProvider] addRoutine: saving routine $name id=${routine.id}');
    await _routineBox.put(routine.id, routine);
    await routine.save();

    _loadExercisesForRoutine(routine);
    debugPrint('[RoutineProvider] addRoutine: saved routine $name');
    notifyListeners();
    try {
      debugPrint('[RoutineProvider] addRoutine: total routines in box=${_routineBox.length}');
    } catch (e) {
      debugPrint('[RoutineProvider] addRoutine: error reading routines count: $e');
    }
    return routine;
  }

  Future<void> updateRoutine(
    Routine routine,
    List<RoutineExercise> updatedExercises,
  ) async {
    final HiveList<RoutineExercise> hiveList = routine.exercises!;

    final List<RoutineExercise> toDelete = [];
    for (var existingExercise in hiveList) {
      if (!updatedExercises.any(
        (element) => element.key == existingExercise.key,
      )) {
        toDelete.add(existingExercise);
      }
    }

    for (var exercise in toDelete) {
      await exercise.delete();
    }

    // Limpiar la HiveList antes de volver a agregar
    hiveList.clear();
    for (var updatedExercise in updatedExercises) {
      if (!updatedExercise.isInBox) {
        await _routineExerciseBox.add(updatedExercise);
      }
      hiveList.add(updatedExercise);
      await updatedExercise.save();
    }

    await routine.save();
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
        .where(
          (log) =>
              log.date.year == date.year &&
              log.date.month == date.month &&
              log.date.day == date.day,
        )
        .toList();
  }
}
