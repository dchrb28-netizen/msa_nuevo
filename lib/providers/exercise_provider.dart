import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/exercise.dart';
import 'package:uuid/uuid.dart';

class ExerciseProvider with ChangeNotifier {
  final Box<Exercise> _exerciseBox = Hive.box<Exercise>('exercises');
  final Uuid _uuid = const Uuid();

  List<Exercise> get exercises => _exerciseBox.values.toList();

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
      icon: exercise.icon,
    );
    await _exerciseBox.put(newExercise.id, newExercise);
    notifyListeners();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _exerciseBox.put(exercise.id, exercise);
    notifyListeners();
  }

  Future<void> deleteExercise(String id) async {
    await _exerciseBox.delete(id);
    notifyListeners();
  }
}
