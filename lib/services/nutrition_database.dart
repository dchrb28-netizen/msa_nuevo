/// Base de datos local de información nutricional por porción
/// Valores aproximados basados en USDA y bases de datos nutricionales
class NutritionDatabase {
  /// Mapa de alimentos con sus macronutrientes por porción estándar
  /// Formato: 'ingrediente' => {calorias, proteina, carbos, grasa, fibra, sodio}
  static const Map<String, Map<String, double>> foodDatabase = {
    // Proteínas - Pollo
    'pechuga de pollo': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6, 'fiber': 0, 'sodium': 73},
    'pollo': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6, 'fiber': 0, 'sodium': 73},
    'pechuga': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6, 'fiber': 0, 'sodium': 73},
    
    // Proteínas - Pescado
    'salmón': {'calories': 208, 'protein': 22, 'carbs': 0, 'fat': 13, 'fiber': 0, 'sodium': 59},
    'atún': {'calories': 132, 'protein': 29, 'carbs': 0, 'fat': 1.3, 'fiber': 0, 'sodium': 47},
    'tilapia': {'calories': 96, 'protein': 20, 'carbs': 0, 'fat': 1, 'fiber': 0, 'sodium': 48},
    'trucha': {'calories': 141, 'protein': 20, 'carbs': 0, 'fat': 6, 'fiber': 0, 'sodium': 57},
    'caballa': {'calories': 159, 'protein': 24, 'carbs': 0, 'fat': 7, 'fiber': 0, 'sodium': 71},
    'pargo': {'calories': 128, 'protein': 26, 'carbs': 0, 'fat': 1.5, 'fiber': 0, 'sodium': 64},
    
    // Proteínas - Carnes
    'res': {'calories': 250, 'protein': 26, 'carbs': 0, 'fat': 15, 'fiber': 0, 'sodium': 75},
    'carne roja': {'calories': 250, 'protein': 26, 'carbs': 0, 'fat': 15, 'fiber': 0, 'sodium': 75},
    'pavo': {'calories': 189, 'protein': 29, 'carbs': 0, 'fat': 7.4, 'fiber': 0, 'sodium': 50},
    'cerdo': {'calories': 242, 'protein': 27, 'carbs': 0, 'fat': 14, 'fiber': 0, 'sodium': 75},
    'cordero': {'calories': 294, 'protein': 25, 'carbs': 0, 'fat': 21, 'fiber': 0, 'sodium': 75},
    
    // Proteínas - Huevos
    'huevo': {'calories': 155, 'protein': 13, 'carbs': 1.1, 'fat': 11, 'fiber': 0, 'sodium': 124},
    'clara de huevo': {'calories': 17, 'protein': 3.6, 'carbs': 0.4, 'fat': 0.1, 'fiber': 0, 'sodium': 166},
    'yema': {'calories': 322, 'protein': 16, 'carbs': 3.3, 'fat': 27, 'fiber': 0, 'sodium': 122},
    
    // Proteínas - Soya
    'tofu': {'calories': 76, 'protein': 8, 'carbs': 1.9, 'fat': 4.8, 'fiber': 1.2, 'sodium': 7},
    'tempeh': {'calories': 165, 'protein': 19, 'carbs': 7.6, 'fat': 9, 'fiber': 6.6, 'sodium': 10},
    'edamame': {'calories': 95, 'protein': 11, 'carbs': 7, 'fat': 4.3, 'fiber': 2.2, 'sodium': 3},
    
    // Carbohidratos - Granos
    'arroz integral': {'calories': 111, 'protein': 2.6, 'carbs': 23, 'fat': 0.9, 'fiber': 1.8, 'sodium': 5},
    'arroz blanco': {'calories': 130, 'protein': 2.7, 'carbs': 28, 'fat': 0.3, 'fiber': 0.4, 'sodium': 2},
    'avena': {'calories': 150, 'protein': 5, 'carbs': 27, 'fat': 3, 'fiber': 4, 'sodium': 2},
    'pasta integral': {'calories': 124, 'protein': 4.3, 'carbs': 25, 'fat': 1.1, 'fiber': 4.5, 'sodium': 7},
    'pan integral': {'calories': 80, 'protein': 3.4, 'carbs': 14, 'fat': 1, 'fiber': 2.7, 'sodium': 149},
    'pan blanco': {'calories': 79, 'protein': 2.7, 'carbs': 14, 'fat': 1, 'fiber': 0.6, 'sodium': 145},
    'quinoa': {'calories': 120, 'protein': 4.4, 'carbs': 21, 'fat': 2.4, 'fiber': 2.8, 'sodium': 9},
    
    // Vegetales - Verdes
    'brócoli': {'calories': 34, 'protein': 2.8, 'carbs': 7, 'fat': 0.4, 'fiber': 2.4, 'sodium': 64},
    'espinaca': {'calories': 23, 'protein': 2.9, 'carbs': 3.6, 'fat': 0.4, 'fiber': 2.2, 'sodium': 79},
    'lechuga': {'calories': 15, 'protein': 1.2, 'carbs': 2.9, 'fat': 0.2, 'fiber': 1.3, 'sodium': 9},
    'acelga': {'calories': 19, 'protein': 1.8, 'carbs': 3.7, 'fat': 0.1, 'fiber': 1.6, 'sodium': 213},
    'kale': {'calories': 49, 'protein': 3.3, 'carbs': 9, 'fat': 0.6, 'fiber': 1.3, 'sodium': 72},
    
    // Vegetales - Crucíferos
    'coliflor': {'calories': 25, 'protein': 1.9, 'carbs': 5, 'fat': 0.3, 'fiber': 2.4, 'sodium': 49},
    'repollo': {'calories': 22, 'protein': 1.3, 'carbs': 5.2, 'fat': 0.1, 'fiber': 2.2, 'sodium': 16},
    
    // Vegetales - Raíces
    'papa': {'calories': 77, 'protein': 2, 'carbs': 17, 'fat': 0.1, 'fiber': 1.7, 'sodium': 7},
    'batata': {'calories': 86, 'protein': 1.6, 'carbs': 20, 'fat': 0.1, 'fiber': 3, 'sodium': 55},
    'camote': {'calories': 86, 'protein': 1.6, 'carbs': 20, 'fat': 0.1, 'fiber': 3, 'sodium': 55},
    'zanahoria': {'calories': 41, 'protein': 0.9, 'carbs': 10, 'fat': 0.2, 'fiber': 2.8, 'sodium': 69},
    'remolacha': {'calories': 43, 'protein': 1.7, 'carbs': 10, 'fat': 0.2, 'fiber': 2.4, 'sodium': 78},
    
    // Vegetales - Otros
    'tomate': {'calories': 18, 'protein': 0.9, 'carbs': 3.9, 'fat': 0.2, 'fiber': 1.2, 'sodium': 6},
    'pepino': {'calories': 16, 'protein': 0.7, 'carbs': 3.6, 'fat': 0.1, 'fiber': 0.5, 'sodium': 2},
    'cebolla': {'calories': 40, 'protein': 1.1, 'carbs': 9, 'fat': 0.1, 'fiber': 1.7, 'sodium': 4},
    'ajo': {'calories': 149, 'protein': 6.4, 'carbs': 33, 'fat': 0.5, 'fiber': 2.1, 'sodium': 17},
    'champiñón': {'calories': 22, 'protein': 3.1, 'carbs': 3.3, 'fat': 0.3, 'fiber': 1, 'sodium': 9},
    
    // Frutas - Cítricas
    'naranja': {'calories': 47, 'protein': 0.9, 'carbs': 12, 'fat': 0.3, 'fiber': 2.4, 'sodium': 0},
    'limón': {'calories': 29, 'protein': 1.1, 'carbs': 9.3, 'fat': 0.3, 'fiber': 2.8, 'sodium': 1},
    'mandarina': {'calories': 47, 'protein': 0.7, 'carbs': 12, 'fat': 0.3, 'fiber': 1.8, 'sodium': 2},
    'pomelo': {'calories': 42, 'protein': 0.8, 'carbs': 11, 'fat': 0.1, 'fiber': 1.6, 'sodium': 0},
    
    // Frutas - Berries
    'fresa': {'calories': 32, 'protein': 0.8, 'carbs': 8, 'fat': 0.3, 'fiber': 2, 'sodium': 2},
    'arándano': {'calories': 57, 'protein': 0.7, 'carbs': 14, 'fat': 0.3, 'fiber': 2.4, 'sodium': 1},
    'mora': {'calories': 43, 'protein': 1.4, 'carbs': 10, 'fat': 0.5, 'fiber': 5.3, 'sodium': 1},
    'frambuesa': {'calories': 52, 'protein': 1.2, 'carbs': 12, 'fat': 0.7, 'fiber': 8, 'sodium': 1},
    
    // Frutas - Tropicales
    'plátano': {'calories': 89, 'protein': 1.1, 'carbs': 23, 'fat': 0.3, 'fiber': 2.6, 'sodium': 1},
    'mango': {'calories': 60, 'protein': 0.8, 'carbs': 15, 'fat': 0.4, 'fiber': 1.6, 'sodium': 2},
    'papaya': {'calories': 43, 'protein': 0.7, 'carbs': 11, 'fat': 0.3, 'fiber': 1.8, 'sodium': 3},
    'piña': {'calories': 50, 'protein': 0.5, 'carbs': 13, 'fat': 0.1, 'fiber': 1.4, 'sodium': 2},
    
    // Frutas - Otras
    'manzana': {'calories': 52, 'protein': 0.3, 'carbs': 14, 'fat': 0.2, 'fiber': 2.4, 'sodium': 1},
    'pera': {'calories': 57, 'protein': 0.4, 'carbs': 15, 'fat': 0.1, 'fiber': 3.1, 'sodium': 1},
    'durazno': {'calories': 39, 'protein': 0.9, 'carbs': 9.5, 'fat': 0.3, 'fiber': 1.5, 'sodium': 0},
    'sandía': {'calories': 30, 'protein': 0.6, 'carbs': 7.6, 'fat': 0.2, 'fiber': 0.4, 'sodium': 1},
    'melón': {'calories': 34, 'protein': 0.8, 'carbs': 8, 'fat': 0.2, 'fiber': 1.4, 'sodium': 16},
    'uva': {'calories': 67, 'protein': 0.7, 'carbs': 17, 'fat': 0.2, 'fiber': 0.9, 'sodium': 2},
    'aguacate': {'calories': 160, 'protein': 2, 'carbs': 9, 'fat': 15, 'fiber': 7, 'sodium': 7},
    'coco': {'calories': 354, 'protein': 3.3, 'carbs': 15, 'fat': 33, 'fiber': 9, 'sodium': 20},
    
    // Grasas - Aceites
    'aceite de oliva': {'calories': 884, 'protein': 0, 'carbs': 0, 'fat': 100, 'fiber': 0, 'sodium': 0},
    'aceite de coco': {'calories': 892, 'protein': 0, 'carbs': 0, 'fat': 100, 'fiber': 0, 'sodium': 0},
    'mantequilla': {'calories': 717, 'protein': 0.9, 'carbs': 0.1, 'fat': 81, 'fiber': 0, 'sodium': 11},
    'ghee': {'calories': 882, 'protein': 0, 'carbs': 0, 'fat': 100, 'fiber': 0, 'sodium': 0},
    
    // Grasas - Nueces
    'almendra': {'calories': 579, 'protein': 21, 'carbs': 22, 'fat': 50, 'fiber': 13, 'sodium': 0},
    'nuez': {'calories': 654, 'protein': 9.1, 'carbs': 14, 'fat': 65, 'fiber': 6.7, 'sodium': 2},
    'cacahuete': {'calories': 567, 'protein': 26, 'carbs': 16, 'fat': 49, 'fiber': 9, 'sodium': 7},
    'avellana': {'calories': 628, 'protein': 15, 'carbs': 17, 'fat': 61, 'fiber': 10, 'sodium': 0},
    'pistacho': {'calories': 562, 'protein': 20, 'carbs': 28, 'fat': 45, 'fiber': 11, 'sodium': 1},
    'semilla de girasol': {'calories': 584, 'protein': 23, 'carbs': 20, 'fat': 51, 'fiber': 9, 'sodium': 9},
    'semilla de calabaza': {'calories': 559, 'protein': 30, 'carbs': 11, 'fat': 49, 'fiber': 6, 'sodium': 5},
    
    // Lácteos
    'yogur': {'calories': 59, 'protein': 10, 'carbs': 3.3, 'fat': 0.4, 'fiber': 0, 'sodium': 51},
    'queso': {'calories': 402, 'protein': 25, 'carbs': 1.3, 'fat': 33, 'fiber': 0, 'sodium': 621},
    'leche': {'calories': 61, 'protein': 3.2, 'carbs': 4.8, 'fat': 3.3, 'fiber': 0, 'sodium': 44},
    'requesón': {'calories': 98, 'protein': 11, 'carbs': 3.9, 'fat': 5, 'fiber': 0, 'sodium': 390},
    
    // Legumbres
    'lentejas': {'calories': 116, 'protein': 9, 'carbs': 20, 'fat': 0.4, 'fiber': 8, 'sodium': 4},
    'garbanzos': {'calories': 134, 'protein': 8.9, 'carbs': 23, 'fat': 2.1, 'fiber': 6.5, 'sodium': 8},
    'frijoles negros': {'calories': 132, 'protein': 8.9, 'carbs': 24, 'fat': 0.5, 'fiber': 8.7, 'sodium': 2},
    'frijol rojo': {'calories': 127, 'protein': 8.7, 'carbs': 23, 'fat': 0.4, 'fiber': 6.4, 'sodium': 2},
    'habas': {'calories': 127, 'protein': 8.6, 'carbs': 23, 'fat': 0.4, 'fiber': 6.5, 'sodium': 2},
  };

  /// Obtener información nutricional de un alimento
  static Map<String, double>? getFoodNutrition(String foodName) {
    final normalized = foodName.toLowerCase().trim();
    
    // Búsqueda exacta
    if (foodDatabase.containsKey(normalized)) {
      return Map<String, double>.from(foodDatabase[normalized]!);
    }
    
    // Búsqueda parcial - si el alimento contiene palabras clave
    for (final entry in foodDatabase.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return Map<String, double>.from(entry.value);
      }
    }
    
    return null;
  }

  /// Calcular macronutrientes a partir de una lista de alimentos
  static Map<String, double> calculateMacrosFromFoods(List<String> foods) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSodium = 0;

    for (final food in foods) {
      final parsed = _parseFoodAndGrams(food);
      final name = parsed['name'] as String;
      final grams = parsed['grams'] as double; // grams, default 100

      final nutrition = getFoodNutrition(name);
      if (nutrition != null) {
        final factor = (grams > 0) ? (grams / 100.0) : 1.0;
        totalCalories += (nutrition['calories'] ?? 0) * factor;
        totalProtein += (nutrition['protein'] ?? 0) * factor;
        totalCarbs += (nutrition['carbs'] ?? 0) * factor;
        totalFat += (nutrition['fat'] ?? 0) * factor;
        totalFiber += (nutrition['fiber'] ?? 0) * factor;
        totalSodium += (nutrition['sodium'] ?? 0) * factor;
      }
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
      'fiber': totalFiber,
      'sodium': totalSodium,
    };
  }

  /// Parsear un texto de alimento y extraer gramos si existe.
  /// Retorna {'name': nombre Limpio, 'grams': double}
  static Map<String, Object> _parseFoodAndGrams(String foodText) {
    final lower = foodText.toLowerCase().trim();

    // Buscar patrón '(123 g)' o '123 g' o '123g'
    final gramRegex = RegExp(r'(\d+(?:[\.,]\d+)?)\s*g');
    final match = gramRegex.firstMatch(lower);
    double grams = 100.0; // por defecto asumimos 100g

    String name = lower;
    if (match != null) {
      final gramText = match.group(1)!.replaceAll(',', '.');
      grams = double.tryParse(gramText) ?? grams;
      // remover la porción del nombre
      name = lower.replaceAll(match.group(0)!, '').trim();
    }

    // Remover porciones entre paréntesis vacíos u otros sufijos tipo '| 420 cal'
    name = name.replaceAll(RegExp(r'\|\s*\d+\s*cal'), '').trim();
    name = name.replaceAll(RegExp(r'[()]'), '').trim();

    return {'name': name, 'grams': grams};
  }

  /// Extraer ingredientes principales de una descripción de comida
  static List<String> extractIngredients(String mealDescription) {
    // Remover la parte de calorías
    final withoutCalories = mealDescription.replaceAll(RegExp(r'\s*\|\s*\d+\s*cal'), '');
    
    // Separar por '+' o ',' y limpiar
    final parts = withoutCalories.split(RegExp(r'\+|,'));
    final ingredients = <String>[];

    for (final part in parts) {
      final cleaned = part.trim();
      if (cleaned.isNotEmpty) {
        // Mantener información entre paréntesis (por ejemplo '(150 g)')
        final ingredient = cleaned.trim();
        if (ingredient.isNotEmpty) {
          ingredients.add(ingredient);
        }
      }
    }

    return ingredients;
  }
}
