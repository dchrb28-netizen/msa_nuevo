import 'package:myapp/services/edamam_service.dart';
import 'package:myapp/services/nutrition_database.dart';

/// Modelo para almacenar información nutricional de una comida
class MealNutritionInfo {
  final String mealName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final bool isFromApi;

  MealNutritionInfo({
    required this.mealName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    this.isFromApi = false,
  });

  /// Obtener macronutrientes como porcentaje de calorías
  Map<String, double> getMacroPercentages() {
    if (calories == 0) return {'protein': 0, 'carbs': 0, 'fat': 0};
    
    final proteinCals = protein * 4;
    final carbsCals = carbs * 4;
    final fatCals = fat * 9;
    final total = proteinCals + carbsCals + fatCals;

    if (total == 0) return {'protein': 0, 'carbs': 0, 'fat': 0};

    return {
      'protein': (proteinCals / total * 100),
      'carbs': (carbsCals / total * 100),
      'fat': (fatCals / total * 100),
    };
  }
}

/// Servicio para obtener información nutricional de comidas
class MealNutritionService {
  static final EdamamService _edamamService = EdamamService();

  /// Obtener información nutricional de una comida completa
  static Future<MealNutritionInfo?> getNutritionForMeal(String mealDescription) async {
    // Primero extraer calorías del texto directamente (ej: "... | 420 cal")
    final caloriesFromText = _extractCaloriesFromText(mealDescription);
    
    // Extraer ingredientes principales para buscar en base de datos local
    final ingredients = NutritionDatabase.extractIngredients(mealDescription);
    
    // Si encontramos ingredientes, calcular macronutrientes desde la BD local
    if (ingredients.isNotEmpty) {
      final macros = NutritionDatabase.calculateMacrosFromFoods(ingredients);
      
      // Si tenemos calorías del texto, usarlas; sino, usar las calculadas
      final finalCalories = caloriesFromText ?? macros['calories'] ?? 0;
      
      // Si al menos obtuvimos algún dato de la BD local, retornar
      if (macros['calories']! > 0 || caloriesFromText != null) {
        return MealNutritionInfo(
          mealName: mealDescription,
          calories: finalCalories,
          protein: macros['protein'] ?? 0,
          carbs: macros['carbs'] ?? 0,
          fat: macros['fat'] ?? 0,
          fiber: macros['fiber'] ?? 0,
          sugar: 0, // No calculamos azúcar en la BD local
          sodium: macros['sodium'] ?? 0,
          isFromApi: false,
        );
      }
    }
    
    // Si ya tenemos calorías del texto pero sin ingredientes identificados
    if (caloriesFromText != null) {
      return MealNutritionInfo(
        mealName: mealDescription,
        calories: caloriesFromText,
        protein: 0.0,
        carbs: 0.0,
        fat: 0.0,
        fiber: 0.0,
        sugar: 0.0,
        sodium: 0.0,
        isFromApi: false,
      );
    }

    // Fallback: intentar obtener de API (como último recurso)
    try {
      var nutrition = await _edamamService.getNutritionInfo(mealDescription);

      if (nutrition == null) {
        final keywords = _extractMainKeywords(mealDescription);
        if (keywords.isNotEmpty) {
          nutrition = await _edamamService.getNutritionInfo(keywords);
        }
      }

      if (nutrition != null) {
        return MealNutritionInfo(
          mealName: mealDescription,
          calories: (nutrition['calories'] as num?)?.toDouble() ?? 0.0,
          protein: (nutrition['protein'] as num?)?.toDouble() ?? 0.0,
          carbs: (nutrition['carbs'] as num?)?.toDouble() ?? 0.0,
          fat: (nutrition['fat'] as num?)?.toDouble() ?? 0.0,
          fiber: (nutrition['fiber'] as num?)?.toDouble() ?? 0.0,
          sugar: (nutrition['sugar'] as num?)?.toDouble() ?? 0.0,
          sodium: (nutrition['sodium'] as num?)?.toDouble() ?? 0.0,
          isFromApi: true,
        );
      }
    } catch (e) {
      // Silenciosamente ignorar errores de API
    }

    return null;
  }

  /// Extraer calorías del texto de la comida (ej: "... | 420 cal")
  static double? _extractCaloriesFromText(String mealDescription) {
    try {
      // Buscar patrón "| XXX cal" o "| XXX-XXX cal" o solo "XXX cal"
      final regex = RegExp(r'\|?\s*(\d+(?:-\d+)?)\s*cal');
      final match = regex.firstMatch(mealDescription);
      
      if (match != null) {
        final calText = match.group(1) ?? '';
        // Si hay rango (ej: 420-450), tomar el promedio
        if (calText.contains('-')) {
          final parts = calText.split('-');
          final cal1 = double.tryParse(parts[0]) ?? 0;
          final cal2 = double.tryParse(parts[1]) ?? 0;
          return (cal1 + cal2) / 2;
        }
        return double.tryParse(calText);
      }
    } catch (e) {
      // Ignorar errores de parsing
    }
    return null;
  }

  /// Extraer palabras clave principales de una descripción de comida
  static String _extractMainKeywords(String description) {
    // Palabras a extraer (proteínas, carbos principales, etc.)
    final keywordPatterns = [
      'pollo',
      'pechuga',
      'salmón',
      'pescado',
      'atún',
      'carne',
      'pavo',
      'huevo',
      'arroz',
      'papa',
      'batata',
      'camote',
      'pasta',
      'pan',
      'ensalada',
      'brócoli',
      'espinaca',
      'verdura',
      'yogur',
      'queso',
      'leche',
      'avena',
      'frutas',
      'plátano',
      'manzana',
      'fresa',
      'aguacate',
    ];

    final lowerDesc = description.toLowerCase();
    final foundKeywords = <String>[];

    for (var pattern in keywordPatterns) {
      if (lowerDesc.contains(pattern)) {
        foundKeywords.add(pattern);
      }
    }

    // Retornar los 3 primeros ingredientes encontrados
    return foundKeywords.take(3).join(' ');
  }

  /// Obtener información nutricional para múltiples comidas en paralelo
  static Future<Map<String, MealNutritionInfo?>> getNutritionForMeals(
    List<String> meals,
  ) async {
    try {
      final futures = meals.map((meal) => getNutritionForMeal(meal));
      final results = await Future.wait(futures);

      final map = <String, MealNutritionInfo?>{};
      for (int i = 0; i < meals.length; i++) {
        map[meals[i]] = results[i];
      }

      return map;
    } catch (e) {
      return {};
    }
  }

  /// Obtener información nutricional para un día completo de comidas
  static Future<Map<String, Map<String, MealNutritionInfo?>>> getNutritionForDay(
    Map<String, String> dayMeals, // e.g., {'Desayuno': 'Avena...', 'Almuerzo': '...'}
  ) async {
    try {
      final mealsList = dayMeals.entries.toList();
      final futures = mealsList.map((entry) => getNutritionForMeal(entry.value));
      final results = await Future.wait(futures);

      final map = <String, Map<String, MealNutritionInfo?>>{};
      
      for (int i = 0; i < mealsList.length; i++) {
        final mealType = mealsList[i].key;
        if (map[mealType] == null) {
          map[mealType] = {};
        }
        map[mealType]![mealsList[i].value] = results[i];
      }

      return map;
    } catch (e) {
      return {};
    }
  }

  /// Obtener estadísticas de un día completo
  static double getDayTotalCalories(List<MealNutritionInfo?> meals) {
    return meals
        .whereType<MealNutritionInfo>()
        .fold(0.0, (sum, meal) => sum + meal.calories);
  }

  static double getDayTotalProtein(List<MealNutritionInfo?> meals) {
    return meals
        .whereType<MealNutritionInfo>()
        .fold(0.0, (sum, meal) => sum + meal.protein);
  }

  static double getDayTotalCarbs(List<MealNutritionInfo?> meals) {
    return meals
        .whereType<MealNutritionInfo>()
        .fold(0.0, (sum, meal) => sum + meal.carbs);
  }

  static double getDayTotalFat(List<MealNutritionInfo?> meals) {
    return meals
        .whereType<MealNutritionInfo>()
        .fold(0.0, (sum, meal) => sum + meal.fat);
  }

  static double getDayTotalFiber(List<MealNutritionInfo?> meals) {
    return meals
        .whereType<MealNutritionInfo>()
        .fold(0.0, (sum, meal) => sum + meal.fiber);
  }

  static double getDayTotalSodium(List<MealNutritionInfo?> meals) {
    return meals
        .whereType<MealNutritionInfo>()
        .fold(0.0, (sum, meal) => sum + meal.sodium);
  }
}
