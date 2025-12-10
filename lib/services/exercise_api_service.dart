import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/exercise.dart';

/// Servicio para obtener ejercicios desde ExerciseDB API (RapidAPI)
/// API gratuita con 1300+ ejercicios y GIFs de alta calidad
/// Límite: 500 requests/día en tier gratuito
class ExerciseApiService {
  static const String _baseUrl = 'https://exercisedb.p.rapidapi.com';
  static const String _apiKey = '0ac953731bmshed20d6a71805c71p1a5fa6jsnf19e05f0eeca';
  
  static const Map<String, String> _headers = {
    'X-RapidAPI-Key': _apiKey,
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
  };

  /// Obtiene lista de todos los ejercicios
  /// Nota: En tier gratuito, limitar a 50-100 ejercicios
  static Future<List<Exercise>> fetchExercises({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _parseExercise(json)).toList();
      } else {
        throw Exception('Error al cargar ejercicios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Busca ejercicios por grupo muscular
  /// bodyPart: chest, back, shoulders, arms, legs, cardio, etc.
  static Future<List<Exercise>> fetchByBodyPart(String bodyPart) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/bodyPart/$bodyPart'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _parseExercise(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Busca ejercicios por equipo necesario
  /// equipment: body weight, dumbbell, barbell, cable, machine, etc.
  static Future<List<Exercise>> fetchByEquipment(String equipment) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/equipment/$equipment'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _parseExercise(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Busca ejercicios por objetivo (target muscle)
  /// target: abs, biceps, triceps, pectorals, lats, quads, glutes, etc.
  static Future<List<Exercise>> fetchByTarget(String target) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/target/$target'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _parseExercise(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Convierte JSON de ExerciseDB a modelo Exercise
  static Exercise _parseExercise(Map<String, dynamic> json) {
    // Mapeo de nombres en inglés a español
    final muscleGroupMap = {
      'chest': 'Pecho',
      'back': 'Espalda',
      'shoulders': 'Hombros',
      'upper arms': 'Brazos',
      'lower arms': 'Brazos',
      'upper legs': 'Piernas',
      'lower legs': 'Piernas',
      'waist': 'Abdomen',
      'cardio': 'Cardio',
    };

    final equipmentMap = {
      'body weight': 'Ninguno',
      'dumbbell': 'Mancuernas',
      'barbell': 'Barra',
      'cable': 'Polea',
      'machine': 'Máquina',
      'kettlebell': 'Kettlebell',
      'resistance band': 'Banda elástica',
      'medicine ball': 'Balón medicinal',
      'stability ball': 'Fitball',
      'assisted': 'Asistido',
      'weighted': 'Lastrado',
    };

    return Exercise(
      id: 'api_${json['id']}',
      name: json['name'] ?? 'Sin nombre',
      description: 'Ejercicio para ${json['target'] ?? 'músculos específicos'}. '
          'Instrucciones: ${(json['instructions'] as List?)?.join(' ') ?? 'Ver demostración'}',
      type: 'Fuerza',
      muscleGroup: muscleGroupMap[json['bodyPart']] ?? 'Otro',
      equipment: equipmentMap[json['equipment']] ?? json['equipment'] ?? 'Ninguno',
      measurement: 'reps',
      imageUrl: json['gifUrl'], // URL del GIF animado
      difficulty: 'Intermedio', // ExerciseDB no provee dificultad
      beginnerSets: '3',
      beginnerReps: '8-12',
      intermediateSets: '4',
      intermediateReps: '12-15',
      advancedSets: '5',
      advancedReps: '15-20',
      recommendations: 'Mantén la forma correcta. Ver GIF para técnica apropiada.',
    );
  }

  /// Obtiene lista de grupos musculares disponibles
  static Future<List<String>> fetchBodyPartList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/bodyPartList'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return List<String>.from(json.decode(response.body));
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtiene lista de equipos disponibles
  static Future<List<String>> fetchEquipmentList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/equipmentList'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return List<String>.from(json.decode(response.body));
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
