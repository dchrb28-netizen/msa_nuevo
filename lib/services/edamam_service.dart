import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config/api_keys.dart';
import 'package:myapp/data/common_foods_database.dart';

/// Servicio para interactuar con la API de Edamam
class EdamamService {
  static final EdamamService _instance = EdamamService._internal();
  factory EdamamService() => _instance;
  EdamamService._internal();

  bool _useOfflineMode = false;

  /// Buscar alimentos (intenta API, fallback a base de datos local)
  Future<List<Map<String, dynamic>>> searchFood(String query) async {
    // Si ya estamos en modo offline, usar base de datos local directamente
    if (_useOfflineMode) {
      return CommonFoodsDatabase.search(query);
    }

    try {
      final url = Uri.parse(
        '${ApiKeys.edamamFoodDatabaseUrl}/parser'
        '?app_id=${ApiKeys.edamamAppId}'
        '&app_key=${ApiKeys.edamamAppKey}'
        '&ingr=${Uri.encodeComponent(query)}'
        '&nutrition-type=logging',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hints = data['hints'] as List<dynamic>? ?? [];
        
        return hints.map((hint) {
          final food = hint['food'] as Map<String, dynamic>;
          final nutrients = food['nutrients'] as Map<String, dynamic>? ?? {};
          
          return {
            'foodId': food['foodId'] ?? '',
            'label': food['label'] ?? 'Desconocido',
            'category': food['category'] ?? 'Generic foods',
            'categoryLabel': food['categoryLabel'] ?? 'Alimento',
            'image': food['image'],
            'nutrients': {
              'calories': nutrients['ENERC_KCAL'] ?? 0.0,
              'protein': nutrients['PROCNT'] ?? 0.0,
              'fat': nutrients['FAT'] ?? 0.0,
              'carbs': nutrients['CHOCDF'] ?? 0.0,
              'fiber': nutrients['FIBTG'] ?? 0.0,
            },
          };
        }).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // API no autorizada, cambiar a modo offline
        _useOfflineMode = true;
        return CommonFoodsDatabase.search(query);
      } else {
        throw Exception('api_error');
      }
    } catch (e) {
      // En cualquier error, usar base de datos local
      _useOfflineMode = true;
      return CommonFoodsDatabase.search(query);
    }
  }

  /// Verificar si estamos en modo offline
  bool get isOfflineMode => _useOfflineMode;

  /// Obtener información nutricional detallada de un alimento
  Future<Map<String, dynamic>?> getNutritionInfo(String ingredient) async {
    try {
      final url = Uri.parse(
        '${ApiKeys.edamamNutritionApiUrl}'
        '?app_id=${ApiKeys.edamamAppId}'
        '&app_key=${ApiKeys.edamamAppKey}'
        '&ingr=${Uri.encodeComponent(ingredient)}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['totalNutrients'] == null) {
          return null;
        }

        final nutrients = data['totalNutrients'] as Map<String, dynamic>;
        final weight = data['totalWeight'] ?? 0.0;

        return {
          'calories': nutrients['ENERC_KCAL']?['quantity'] ?? 0.0,
          'protein': nutrients['PROCNT']?['quantity'] ?? 0.0,
          'fat': nutrients['FAT']?['quantity'] ?? 0.0,
          'carbs': nutrients['CHOCDF']?['quantity'] ?? 0.0,
          'fiber': nutrients['FIBTG']?['quantity'] ?? 0.0,
          'sugar': nutrients['SUGAR']?['quantity'] ?? 0.0,
          'sodium': nutrients['NA']?['quantity'] ?? 0.0,
          'weight': weight,
        };
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener información nutricional: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión con Edamam: $e');
    }
  }

  /// Buscar recetas en Edamam
  Future<List<Map<String, dynamic>>> searchRecipes({
    required String query,
    String? mealType, // breakfast, lunch, dinner, snack
    String? dishType, // main course, side dish, dessert, etc.
    int maxResults = 20,
  }) async {
    try {
      var url = '${ApiKeys.edamamRecipeSearchUrl}'
          '?type=public'
          '&app_id=${ApiKeys.edamamAppId}'
          '&app_key=${ApiKeys.edamamAppKey}'
          '&q=${Uri.encodeComponent(query)}'
          '&to=$maxResults';

      if (mealType != null) {
        url += '&mealType=$mealType';
      }
      if (dishType != null) {
        url += '&dishType=$dishType';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hits = data['hits'] as List<dynamic>? ?? [];

        return hits.map((hit) {
          final recipe = hit['recipe'] as Map<String, dynamic>;
          final nutrients = recipe['totalNutrients'] as Map<String, dynamic>? ?? {};

          return {
            'label': recipe['label'] ?? 'Sin nombre',
            'image': recipe['image'],
            'source': recipe['source'] ?? 'Desconocido',
            'url': recipe['url'],
            'yield': recipe['yield'] ?? 1,
            'calories': recipe['calories'] ?? 0.0,
            'ingredients': (recipe['ingredientLines'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ?? [],
            'nutrients': {
              'protein': nutrients['PROCNT']?['quantity'] ?? 0.0,
              'fat': nutrients['FAT']?['quantity'] ?? 0.0,
              'carbs': nutrients['CHOCDF']?['quantity'] ?? 0.0,
              'fiber': nutrients['FIBTG']?['quantity'] ?? 0.0,
            },
            'mealType': recipe['mealType'] ?? [],
            'dishType': recipe['dishType'] ?? [],
            'cuisineType': recipe['cuisineType'] ?? [],
          };
        }).toList();
      } else {
        throw Exception('Error al buscar recetas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión con Edamam: $e');
    }
  }
}
