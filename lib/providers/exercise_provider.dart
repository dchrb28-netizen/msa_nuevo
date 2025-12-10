import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/data/exercise_list.dart' as exercise_data;
import 'package:uuid/uuid.dart';

class ExerciseProvider with ChangeNotifier {
  final Box<Exercise> _exerciseBox = Hive.box<Exercise>('exercises');
  final Uuid _uuid = const Uuid();

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ExerciseProvider() {
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Clear the box to ensure fresh data from the hardcoded list on every app start.
      await _exerciseBox.clear();

      // Load exercises from the static list and put them into the box.
      for (final exercise in exercise_data.exercises) {
        // If the exercise doesn't provide an imageUrl, use a gif asset based on its id.
        final fallbackImage = 'assets/exercise_gifs/${exercise.id}.gif';
        final newExercise = Exercise(
          id: exercise.id,
          name: exercise.name,
          description: exercise.description,
          type: exercise.type,
          muscleGroup: exercise.muscleGroup,
          equipment: exercise.equipment,
          measurement: exercise.measurement,
          imageUrl: exercise.imageUrl ?? fallbackImage,
          videoUrl: exercise.videoUrl,
          difficulty: exercise.difficulty,
          beginnerSets: exercise.beginnerSets,
          beginnerReps: exercise.beginnerReps,
          intermediateSets: exercise.intermediateSets,
          intermediateReps: exercise.intermediateReps,
          advancedSets: exercise.advancedSets,
          advancedReps: exercise.advancedReps,
          recommendations: exercise.recommendations,
        );
        await _exerciseBox.put(newExercise.id, newExercise);
      }

      // Load the fresh exercises from the box into the provider's list.
      _exercises = _exerciseBox.values.toList();
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      difficulty: exercise.difficulty,
      beginnerSets: exercise.beginnerSets,
      beginnerReps: exercise.beginnerReps,
      intermediateSets: exercise.intermediateSets,
      intermediateReps: exercise.intermediateReps,
      advancedSets: exercise.advancedSets,
      advancedReps: exercise.advancedReps,
      recommendations: exercise.recommendations,
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

  // Method to get a single exercise by its ID
  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      // If no element is found, firstWhere throws a StateError.
      // We catch it and return null for safety.
      return null;
    }
  }
}
