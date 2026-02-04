import 'package:myapp/data/meal_plan_templates.dart';
import 'package:myapp/models/user.dart';

/// Servicio para personalizar planes de comidas según preferencias del usuario
class PersonalizedMealPlanService {
  /// Sustituir comidas según preferencias del usuario
  static Map<String, Map<String, String>> customizePlan(
    String planName,
    User? user,
  ) {
    // soportar variantes en el nombre del plan: "Plan - Vegano"
    final parts = planName.split(RegExp(r'\s-\s'));
    final baseName = parts.first;
    final variant = parts.length > 1 ? parts.sublist(1).join(' - ') : null;

    final basePlan = MealPlanTemplates.allPlans[baseName];

    if (basePlan == null || user == null) {
      return basePlan ?? {};
    }

    // Crear una copia del plan
    final customizedPlan = <String, Map<String, String>>{};

    basePlan.forEach((day, meals) {
      customizedPlan[day] = {};

      meals.forEach((mealType, mealContent) {
        String finalMeal = mealContent;
        
        // Verificar si algún ingrediente es alérgeno (PRIORIDAD MÁXIMA)
        if (_containsAllergen(mealContent, user.allergens)) {
          // Reemplazar con alternativa SEGURA (sin alérgenos)
          finalMeal = _findSafeAlternativeMeal(
            mealType,
            user.favoriteRawFoods,
            user.dislikedFoods,
            user.allergens,
            // combinar preferencias del usuario con la variante del plan
            ((user.dietaryPreferences ?? '') + (variant != null ? (',' + variant) : '')).trim(),
            baseName,
          );
        } 
        // Verificar si contiene alimentos que no le gustan
        else if (_containsDislikedFood(mealContent, user.dislikedFoods)) {
          // Reemplazar con alternativa
          finalMeal = _findSafeAlternativeMeal(
            mealType,
            user.favoriteRawFoods,
            user.dislikedFoods,
            user.allergens,
            ((user.dietaryPreferences ?? '') + (variant != null ? (',' + variant) : '')).trim(),
            baseName,
          );
        }
        // Si tiene alimentos favoritos definidos, SOLO usar comidas con esos ingredientes
        else if (user.favoriteRawFoods.isNotEmpty) {
          // Verificar si la comida actual contiene algún favorito
          if (!_containsAnyFavorite(mealContent, user.favoriteRawFoods)) {
            // No contiene favoritos, DEBE reemplazarse con una que sí los tenga
            finalMeal = _findMealWithFavoritesOnly(
              mealType,
              user.favoriteRawFoods,
              user.allergens,
              user.dislikedFoods,
              ((user.dietaryPreferences ?? '') + (variant != null ? (',' + variant) : '')).trim(),
              baseName,
            );
          }
        }
        
        // VERIFICACIÓN FINAL DE SEGURIDAD: Nunca incluir alérgenos
        if (_containsAllergen(finalMeal, user.allergens)) {
          // Si aún contiene alérgenos, buscar última alternativa segura
          finalMeal = _getEmergencySafeMeal(mealType, user.allergens);
        }
        
        customizedPlan[day]![mealType] = _ensurePortionIfMissing(finalMeal, mealType);
      });
    });

    return customizedPlan;
  }

  /// Verificar si una comida contiene alérgenos
  static bool _containsAllergen(String meal, List<String> allergens) {
    final lowerMeal = meal.toLowerCase();
    return allergens.any((allergen) => lowerMeal.contains(allergen.toLowerCase()));
  }

  /// Verificar si una comida contiene alimentos que no le gustan
  static bool _containsDislikedFood(String meal, List<String> dislikedFoods) {
    final lowerMeal = meal.toLowerCase();
    return dislikedFoods.any((food) => lowerMeal.contains(food.toLowerCase()));
  }

  /// Verificar si una comida contiene al menos uno de los alimentos favoritos
  static bool _containsAnyFavorite(String meal, List<String> favorites) {
    if (favorites.isEmpty) return true; // Si no hay favoritos, todo es válido
    final lowerMeal = meal.toLowerCase();
    return favorites.any((favorite) => lowerMeal.contains(favorite.toLowerCase()));
  }

  /// Encontrar comida que SOLO contenga ingredientes de la lista de favoritos
  static String _findMealWithFavoritesOnly(
    String mealType,
    List<String> favoriteRawFoods,
    List<String> allergens,
    List<String> dislikedFoods,
    String? dietaryPreferences,
    String planName,
  ) {
    final alternatives = _getMealAlternatives(mealType, planName);
    final prefs = (dietaryPreferences ?? '').toLowerCase();
    bool vegan = prefs.contains('vegano');
    bool vegetarian = prefs.contains('vegetariano');
    bool noSugar = prefs.contains('sin azucar') || prefs.contains('sin azúcar');

    // Filtrar alternativas que contengan al menos un favorito
    List<String> withFavorites = alternatives.where((alt) {
      final lower = alt.toLowerCase();
      
      // DEBE contener al menos uno de los favoritos
      bool hasFavorite = false;
      for (var favorite in favoriteRawFoods) {
        if (lower.contains(favorite.toLowerCase())) {
          hasFavorite = true;
          break;
        }
      }
      if (!hasFavorite) return false;

      // NO debe contener alérgenos (prioridad máxima)
      if (_containsAllergen(alt, allergens)) return false;

      // NO debe contener alimentos no deseados
      if (_containsDislikedFood(alt, dislikedFoods)) return false;

      // Aplicar filtros dietéticos
      if (vegan) {
        final animalTerms = ['pollo', 'pavo', 'res', 'cerdo', 'cordero', 'salmon', 'salmón', 'atún', 'atun', 'huevo', 'queso', 'yogur', 'leche', 'mantequilla', 'huevos', 'pescado', 'filete'];
        if (animalTerms.any((t) => lower.contains(t))) return false;
      }

      if (vegetarian && !vegan) {
        final meatTerms = ['pollo', 'pavo', 'res', 'cerdo', 'cordero', 'salmon', 'salmón', 'atún', 'atun', 'pescado', 'filete'];
        if (meatTerms.any((t) => lower.contains(t))) return false;
      }

      if (noSugar) {
        final sugarTerms = ['miel', 'azúcar', 'azucar', 'marmelada', 'jarabe', 'dulce'];
        if (sugarTerms.any((t) => lower.contains(t))) return false;
      }

      return true;
    }).toList();

    // Si encontramos opciones válidas, retornar la primera
    if (withFavorites.isNotEmpty) {
      return withFavorites.first;
    }

    // Si no hay opciones con favoritos, crear comida genérica con los favoritos
    return _buildGenericMealWithFavorites(mealType, favoriteRawFoods, dietaryPreferences);
  }

  /// Construir comida genérica usando los ingredientes favoritos
  static String _buildGenericMealWithFavorites(
    String mealType,
    List<String> favoriteRawFoods,
    String? dietaryPreferences,
  ) {
    if (favoriteRawFoods.isEmpty) {
      return _getEmergencySafeMeal(mealType, []);
    }

    final prefs = (dietaryPreferences ?? '').toLowerCase();
    bool vegan = prefs.contains('vegano');

    // Seleccionar un favorito aleatorio para la comida
    final mainIngredient = favoriteRawFoods.first;
    
    // Crear comida según el tipo
    switch (mealType) {
      case 'Desayuno':
        if (vegan) {
          return 'Batido de $mainIngredient con frutas';
        }
        return 'Desayuno con $mainIngredient y huevos';
      
      case 'Almuerzo':
        if (vegan) {
          return '$mainIngredient con arroz integral y vegetales';
        }
        return '$mainIngredient a la plancha con ensalada y arroz';
      
      case 'Cena':
        if (vegan) {
          return '$mainIngredient salteado con vegetales';
        }
        return '$mainIngredient al horno con vegetales';
      
      case 'Snacks':
        return '$mainIngredient fresco';
      
      default:
        return '$mainIngredient con vegetales';
    }
  }

  /// Encontrar comida alternativa segura (sin alérgenos)
  static String _findSafeAlternativeMeal(
    String mealType,
    List<String> favoriteRawFoods,
    List<String> dislikedFoods,
    List<String> allergens,
    String? dietaryPreferences,
    String planName,
  ) {
    final alternatives = _getMealAlternatives(mealType, planName);

    // Construir reglas simples de exclusión según dietaryPreferences
    final prefs = (dietaryPreferences ?? '').toLowerCase();
    bool vegan = prefs.contains('vegano');
    bool vegetarian = prefs.contains('vegetariano');
    bool noSugar = prefs.contains('sin azucar') || prefs.contains('sin azúcar');

    List<String> filtered = alternatives.where((alt) {
      final lower = alt.toLowerCase();

      // PRIORIDAD 1: NUNCA incluir alérgenos
      if (_containsAllergen(lower, allergens)) return false;

      // Evitar alimentos no deseados del usuario
      if (_containsDislikedFood(lower, dislikedFoods)) return false;

      // Vegano: evitar productos animales
      if (vegan) {
        final animalTerms = ['pollo', 'pavo', 'res', 'cerdo', 'cordero', 'salmon', 'salmón', 'atún', 'atun', 'huevo', 'queso', 'yogur', 'leche', 'mantequilla', 'huevos', 'pescado', 'filete'];
        if (animalTerms.any((t) => lower.contains(t))) return false;
      }

      // Vegetariano: evitar carnes / pescados, permitir huevos/lácteos
      if (vegetarian && !vegan) {
        final meatTerms = ['pollo', 'pavo', 'res', 'cerdo', 'cordero', 'salmon', 'salmón', 'atún', 'atun', 'pescado', 'filete'];
        if (meatTerms.any((t) => lower.contains(t))) return false;
      }

      // Sin azúcar: evitar palabras obvias relacionadas con dulces o miel
      if (noSugar) {
        final sugarTerms = ['miel', 'azúcar', 'azucar', 'marmelada', 'jarabe', 'dulce', 'miel'];
        if (sugarTerms.any((t) => lower.contains(t))) return false;
      }

      return true;
    }).toList();

    // PRIORIDAD 1: Preferir comidas que contienen alimentos favoritos Y son seguras
    if (favoriteRawFoods.isNotEmpty) {
      for (var alt in filtered) {
        for (var favorite in favoriteRawFoods) {
          if (alt.toLowerCase().contains(favorite.toLowerCase())) {
            return alt; // Favorito encontrado que es seguro
          }
        }
      }
    }

    // PRIORIDAD 2: Retornar la primera alternativa segura (sin alérgenos ni alimentos no deseados)
    if (filtered.isNotEmpty) {
      return filtered.first;
    }

    // PRIORIDAD 3: Si no hay alternativas filtradas, buscar cualquiera sin alérgenos
    for (var alt in alternatives) {
      if (!_containsAllergen(alt, allergens) && !_containsDislikedFood(alt, dislikedFoods)) {
        return alt;
      }
    }

    // ÚLTIMA OPCIÓN: Alternativa genérica segura
    return _getEmergencySafeMeal(mealType, allergens);
  }

  /// Obtener comida de emergencia segura (sin alérgenos comunes)
  static String _getEmergencySafeMeal(String mealType, List<String> allergens) {
    final safeMeals = {
      'Desayuno': [
        'Avena con agua y frutas',
        'Arroz integral con manzana',
        'Pan de arroz con aguacate',
        'Batido de frutas variadas',
        'Ensalada de frutas frescas',
      ],
      'Almuerzo': [
        'Arroz blanco con vegetales al vapor',
        'Quinoa con brócoli y zanahoria',
        'Lentejas con arroz integral',
        'Ensalada verde con garbanzos',
        'Papa al horno con vegetales',
      ],
      'Cena': [
        'Vegetales salteados con arroz',
        'Sopa de vegetales casera',
        'Ensalada mixta con quinoa',
        'Puré de papa con brócoli',
        'Arroz con verduras al vapor',
      ],
      'Snacks': [
        'Frutas frescas variadas',
        'Palitos de zanahoria y apio',
        'Manzana en rodajas',
        'Uvas frescas',
        'Naranja en gajos',
      ],
    };

    final options = safeMeals[mealType] ?? safeMeals['Snacks']!;
    
    // Buscar la primera opción que no contenga alérgenos
    for (var meal in options) {
      if (!_containsAllergen(meal, allergens)) {
        return meal;
      }
    }
    
    // Si todas contienen alérgenos, retornar la más básica
    return 'Arroz blanco con vegetales al vapor';
  }

  /// Añadir porción por defecto si el texto de la comida no contiene gramos
  static String _ensurePortionIfMissing(String mealContent, String mealType) {
    final lower = mealContent.toLowerCase();
    final gramRegex = RegExp(r'\d+\s*g');
    if (gramRegex.hasMatch(lower)) return mealContent;

    // Valores por defecto (en gramos) por tipo de comida
    final defaults = {
      'Desayuno': 350,
      'Almuerzo': 600,
      'Cena': 500,
      'Snacks': 100,
    };

    final grams = defaults[mealType] ?? 200;

    return '$mealContent | ${grams.toString()} g';
  }

  /// Obtener alternativas de comida según el tipo y plan
  static List<String> _getMealAlternatives(String mealType, String planName) {
    final alternatives = {
      'Desayuno': [
        // Huevo
        'Huevos revueltos con tostada integral',
        'Huevos poché con pan tostado',
        'Tortilla de vegetales',
        'Huevos rellenos de queso',
        // Avena y Cereales
        'Avena con manzana y canela',
        'Avena con arándanos y miel',
        'Avena con banana y nueces',
        'Granola casera con yogur',
        'Cereal integral con leche',
        // Yogur
        'Yogur griego con frutas',
        'Yogur natural con granola',
        'Yogur con miel y almendras',
        'Parfait de yogur con frutas',
        // Batidos
        'Batido de proteína con plátano',
        'Batido verde con espinaca y frutas',
        'Smoothie de arándanos y yogur',
        'Batido de fresa y plátano',
        'Batido de proteína con cacao',
        // Frutas
        'Frutas frescas variadas',
        'Melón con jamón',
        'Piña fresca con yogur',
        // Panes
        'Pan integral tostado con aguacate',
        'Pan tostado con tomate y queso',
        'Bagel integral con salmón',
        // Otros
        'Pancakes integrales con arándanos',
        'Tostadas francesas sin azúcar',
        'Budín de chía con leche de almendra',
      ],
      'Almuerzo': [
        // Pollo
        'Pechuga de pollo a la parrilla con verduras',
        'Pollo al horno con papa y ensalada',
        'Milanesa de pollo con puré',
        'Pollo salteado con vegetales',
        'Sopa de pollo y vegetales',
        'Filete de pollo relleno de queso',
        // Carne de res
        'Filete a la parrilla con papas y vegetales',
        'Estofado de carne con vegetales',
        'Carne molida con arroz integral',
        'Hamburguesa casera con ensalada',
        'Bife con papas al horno',
        // Pescados
        'Salmón al horno con limón',
        'Atún a la parrilla con vegetales',
        'Filete de tilapia frito',
        'Trucha rellena de hierbas',
        'Ceviche de pescado blanco',
        // Arroces
        'Arroz integral con pollo y vegetales',
        'Arroz blanco con legumbres',
        'Risotto de setas y queso',
        'Paella de mariscos',
        // Pastas
        'Pasta integral con salsa de tomate',
        'Pasta con pesto y pollo',
        'Fideos a lo wok con vegetales',
        'Lasaña integral',
        // Legumbres
        'Sopa de lentejas y vegetales',
        'Garbanzos guisados',
        'Chili de frijoles',
        'Habas salteadas',
        // Ensaladas
        'Ensalada de lechuga con proteína',
        'Ensalada mediterránea',
        'Ensalada de remolacha y queso',
        'Ensalada tibia de vegetales',
        // Sandwiches
        'Sándwich de pavo y queso',
        'Sándwich de atún con vegetales',
        'Wrap integral con pollo',
        // Otros
        'Quesadilla integral con pollo',
        'Tacos de carne molida',
        'Bowl de arroz con proteína',
      ],
      'Cena': [
        // Pescados
        'Pescado blanco al horno con papas',
        'Salmón a la mantequilla con espárragos',
        'Filete de trucha con vegetales',
        'Bacalao al ajillo con puré',
        'Calamar a la plancha',
        // Pollo
        'Pechuga a la plancha con brócoli',
        'Pollo al horno con verduras asadas',
        'Pechuga marinada con ensalada',
        'Pollo relleno de espinaca',
        'Alitas al horno con vegetales',
        // Carne
        'Estofado de carne con vegetales',
        'Carne molida con calabacín',
        'Lomo salteado con vegetales',
        'Carne asada con papas',
        'Carne guisada',
        // Vegetariano
        'Tofu salteado con vegetales',
        'Pimiento relleno de queso y vegetales',
        'Espagueti de calabacín',
        'Coliflor gratinada',
        'Berenjenas rellenas',
        // Huevo
        'Tortilla española con ensalada',
        'Huevos a la cazuela',
        'Revuelto de vegetales con huevo',
        // Otros
        'Sopa de vegetales con pollo',
        'Crema de verduras con pollo',
        'Arroz con vegetales y proteína',
        'Fideos salteados con proteína',
        'Guiso casero de verduras',
      ],
      'Snacks': [
        // Frutas
        'Manzana fresca',
        'Plátano',
        'Naranja',
        'Fresas frescas',
        'Arándanos',
        'Frambuesas',
        'Piña fresca',
        'Kiwi',
        'Pera',
        'Uva',
        'Cereza',
        'Papaya',
        'Melón',
        // Frutos Secos
        'Almendras sin sal',
        'Nueces',
        'Avellanas',
        'Anacardos',
        'Pistachos',
        'Semillas de girasol',
        'Semillas de calabaza',
        'Mix de frutos secos',
        // Lácteos
        'Yogur natural',
        'Queso fresco',
        'Queso tipo fiambre',
        'Leche descremada fría',
        'Yogur con frutas',
        // Proteínas
        'Huevo cocido',
        'Pavo frío',
        'Jamón de pavo',
        'Atún enlatado en agua',
        'Pollo cocido',
        // Barras
        'Barra de cereales casera',
        'Barra de proteína',
        'Barra de granola',
        // Otros
        'Zanahorias crudas',
        'Pepino fresco',
        'Tomate cherry',
        'Pimiento rojo',
        'Palomitas sin sal',
        'Galletas integrales',
        'Pan integral tostado',
        'Chocolate oscuro 70%',
        'Batido de proteína',
        'Agua de coco',
      ],
    };

    return alternatives[mealType] ?? alternatives['Snacks']!;
  }

  /// Obtener descripción de restricciones del usuario
  static String getRestrictionsDescription(User? user) {
    if (user == null) return 'Sin restricciones';

    final restrictions = <String>[];

    if (user.dislikedFoods.isNotEmpty) {
      restrictions.add('Excluir: ${user.dislikedFoods.join(", ")}');
    }

    if (user.allergens.isNotEmpty) {
      restrictions.add('Alergias: ${user.allergens.join(", ")}');
    }

    if (user.favoriteRawFoods.isNotEmpty) {
      restrictions.add('Favoritos: ${user.favoriteRawFoods.join(", ")}');
    }

    return restrictions.isEmpty ? 'Sin restricciones' : restrictions.join(' • ');
  }
}
