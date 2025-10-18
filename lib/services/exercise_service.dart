import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:myapp/models/exercise.dart';
import 'package:path_provider/path_provider.dart';

class ExerciseService {
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
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Exercise.fromJson(json)).toList();
    } catch (e, s) {
      developer.log(
        'Error al cargar los ejercicios',
        name: 'ExerciseService.load',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Future<void> saveExercises(List<Exercise> exercises) async {
    try {
      final file = await _localFile;
      final jsonList = exercises.map((exercise) => exercise.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e, s) {
      developer.log(
        'Error al guardar los ejercicios',
        name: 'ExerciseService.save',
        error: e,
        stackTrace: s,
      );
    }
  }
}
