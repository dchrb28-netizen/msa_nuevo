import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:myapp/data/exercise_list.dart';
import 'package:myapp/models/exercise.dart';
import 'package:uuid/uuid.dart';

class ExerciseProvider with ChangeNotifier {
  final Box<Exercise> _exerciseBox = Hive.box<Exercise>('exercises');
  final Uuid _uuid = const Uuid();

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  ExerciseProvider() {
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    // Clear the box to ensure fresh data
    await _exerciseBox.clear();

    for (final exercise in exerciseList) {
        await _exerciseBox.put(exercise.id, exercise);
    }
    
    _exercises = _exerciseBox.values.toList();
    notifyListeners();
  }

  Future<void> addExercise(Exercise exercise) async {
    final newExercise = Exercise(
      id: _uuid.v4(),
      name: exercise.name,
      description: exercise.description,
      type: exercise.type,
      muscleGroup: exercise.muscleGroup,
      equipment: exercise.equipment,
      measurement: exercise.measurement,
      imageUrl: exercise.imageUrl,
      videoUrl: exercise.videoUrl,
    );
    await _exerciseBox.put(newExercise.id, newExercise);
    _exercises.add(newExercise);
    notifyListeners();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _exerciseBox.put(exercise.id, exercise);
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      _exercises[index] = exercise;
      notifyListeners();
    }
  }

  Future<void> deleteExercise(String id) async {
    await _exerciseBox.delete(id);
    _exercises.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
