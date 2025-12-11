import 'dart:convert';
import 'dart:io';

import 'package:myapp/models/exercise.dart';
import 'package:path_provider/path_provider.dart';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  List<Exercise> _exercises = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/exercises.json');
  }

  Future<List<Exercise>> loadExercises() async {
    try {
      final file = await _localFile;

      if (!file.existsSync()) {
        _exercises = _getDefaultExercises();
        await _saveExercises();
        return _exercises;
      }

      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      _exercises = json.map((e) => Exercise.fromJson(e)).toList();
      return _exercises;
    } catch (e) {
      // If there is an error, return the default list of exercises
      _exercises = _getDefaultExercises();
      return _exercises;
    }
  }

  Future<void> _saveExercises() async {
    final file = await _localFile;
    final json = _exercises.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }

  Future<void> addExercise(Exercise exercise) async {
    _exercises.add(exercise);
    await _saveExercises();
  }

  Future<void> updateExercise(Exercise exercise) async {
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      _exercises[index] = exercise;
      await _saveExercises();
    }
  }

  Future<void> deleteExercise(String id) async {
    _exercises.removeWhere((e) => e.id == id);
    await _saveExercises();
  }

  // This function is now deprecated. The ExerciseProvider populates data from the main list.
  // Returning an empty list to satisfy the analyzer and avoid using old data.
  List<Exercise> _getDefaultExercises() {
    return [];
  }
}
