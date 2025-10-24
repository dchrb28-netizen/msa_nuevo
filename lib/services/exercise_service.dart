import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
      // Si hay un error, devolvemos la lista de ejercicios por defecto
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

  List<Exercise> _getDefaultExercises() {
    return [
      Exercise(
        id: '1',
        name: 'Press de Banca',
        muscleGroup: 'Pecho',
        equipment: 'Barra',
        description: 'Descripción del ejercicio...',
        type: 'Fuerza',
        measurement: 'reps',
        icon: Icons.fitness_center,
      ),
      Exercise(
        id: '2',
        name: 'Sentadilla',
        muscleGroup: 'Piernas',
        equipment: 'Barra',
        description: 'Descripción del ejercicio...',
        type: 'Fuerza',
        measurement: 'reps',
        icon: Icons.fitness_center,
      ),
      Exercise(
        id: '3',
        name: 'Peso Muerto',
        muscleGroup: 'Espalda',
        equipment: 'Barra',
        description: 'Descripción del ejercicio...',
        type: 'Fuerza',
        measurement: 'reps',
        icon: Icons.fitness_center,
      ),
      Exercise(
        id: '4',
        name: 'Press Militar',
        muscleGroup: 'Hombros',
        equipment: 'Barra',
        description: 'Descripción del ejercicio...',
        type: 'Fuerza',
        measurement: 'reps',
        icon: Icons.fitness_center,
      ),
      Exercise(
        id: '5',
        name: 'Remo con Barra',
        muscleGroup: 'Espalda',
        equipment: 'Barra',
        description: 'Descripción del ejercicio...',
        type: 'Fuerza',
        measurement: 'reps',
        icon: Icons.fitness_center,
      ),
      Exercise(
        id: '6',
        name: 'Curl de Bíceps',
        muscleGroup: 'Brazos',
        equipment: 'Mancuernas',
        description: 'Descripción del ejercicio...',
        type: 'Fuerza',
        measurement: 'reps',
        icon: Icons.fitness_center,
      ),
      Exercise(
        id: '7',
        name: 'Extensiones de Tríceps',
        muscleGroup: 'Brazos',
        equipment: 'Mancuernas',
        description: 'Descripción del ejercicio...',
        type: 'Fuerza',
        measurement: 'reps',
        icon: Icons.fitness_center,
      ),
      Exercise(
        id: '8',
        name: 'Elevaciones Laterales',
        muscleGroup: 'Hombros',
        equipment: 'Mancuernas',
        description: 'Descripción del ejercicio...',
        type: 'Fuerza',
        measurement: 'reps',
        icon: Icons.fitness_center,
      ),
      Exercise(
        id: '9',
        name: 'Zancadas',
        muscleGroup: 'Piernas',
        equipment: 'Mancuernas',
        description: 'Descripción del ejercicio...',
        type: 'Fuerza',
        measurement: 'reps',
        icon: Icons.fitness_center,
      ),
      Exercise(
        id: '10',
        name: 'Plancha',
        muscleGroup: 'Abdomen',
        equipment: 'Peso corporal',
        description: 'Descripción del ejercicio...',
        type: 'Resistencia',
        measurement: 'time',
        icon: Icons.fitness_center,
      ),
    ];
  }
}
