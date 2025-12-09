/// Base de datos local de alimentos comunes
/// Usada como fallback cuando la API de Edamam no está disponible
class CommonFoodsDatabase {
  static final List<Map<String, dynamic>> foods = [
    // Frutas
    {
      'foodId': 'local_apple',
      'label': 'Manzana',
      'category': 'fruit',
      'categoryLabel': 'Frutas',
      'image': 'https://www.edamam.com/food-img/42c/42c006401027d35add93113548eeaae6.jpg',
      'nutrients': {
        'calories': 52.0,
        'protein': 0.3,
        'fat': 0.2,
        'carbs': 14.0,
        'fiber': 2.4,
      },
    },
    {
      'foodId': 'local_banana',
      'label': 'Plátano',
      'category': 'fruit',
      'categoryLabel': 'Frutas',
      'image': 'https://www.edamam.com/food-img/9f6/9f6181163a25c96022ee3fc66d9ebb11.jpg',
      'nutrients': {
        'calories': 89.0,
        'protein': 1.1,
        'fat': 0.3,
        'carbs': 23.0,
        'fiber': 2.6,
      },
    },
    {
      'foodId': 'local_orange',
      'label': 'Naranja',
      'category': 'fruit',
      'categoryLabel': 'Frutas',
      'image': 'https://www.edamam.com/food-img/8ea/8ea264a802d6e643c1a340a77863c6ef.jpg',
      'nutrients': {
        'calories': 47.0,
        'protein': 0.9,
        'fat': 0.1,
        'carbs': 12.0,
        'fiber': 2.4,
      },
    },
    {
      'foodId': 'local_strawberry',
      'label': 'Fresa',
      'category': 'fruit',
      'categoryLabel': 'Frutas',
      'image': 'https://www.edamam.com/food-img/00c/00c8851cf3ee9ffe9b5c12d7f8f03b19.jpg',
      'nutrients': {
        'calories': 32.0,
        'protein': 0.7,
        'fat': 0.3,
        'carbs': 8.0,
        'fiber': 2.0,
      },
    },
    
    // Proteínas
    {
      'foodId': 'local_chicken_breast',
      'label': 'Pechuga de Pollo',
      'category': 'protein',
      'categoryLabel': 'Proteínas',
      'image': 'https://www.edamam.com/food-img/d33/d338229d774a743f7858f6764e095878.jpg',
      'nutrients': {
        'calories': 165.0,
        'protein': 31.0,
        'fat': 3.6,
        'carbs': 0.0,
        'fiber': 0.0,
      },
    },
    {
      'foodId': 'local_eggs',
      'label': 'Huevo',
      'category': 'protein',
      'categoryLabel': 'Proteínas',
      'image': 'https://www.edamam.com/food-img/a7e/a7ec7c337cb47c6550b3b118e357f077.jpg',
      'nutrients': {
        'calories': 155.0,
        'protein': 13.0,
        'fat': 11.0,
        'carbs': 1.1,
        'fiber': 0.0,
      },
    },
    {
      'foodId': 'local_salmon',
      'label': 'Salmón',
      'category': 'protein',
      'categoryLabel': 'Proteínas',
      'image': 'https://www.edamam.com/food-img/9a0/9a0f38422e9f21dcedbc2ddb0d1e53eb.jpg',
      'nutrients': {
        'calories': 208.0,
        'protein': 20.0,
        'fat': 13.0,
        'carbs': 0.0,
        'fiber': 0.0,
      },
    },
    
    // Carbohidratos
    {
      'foodId': 'local_rice',
      'label': 'Arroz Blanco',
      'category': 'grains',
      'categoryLabel': 'Cereales',
      'image': 'https://www.edamam.com/food-img/0fc/0fc9fa8d3e0c85bdb05ba3888265bbf5.jpg',
      'nutrients': {
        'calories': 130.0,
        'protein': 2.7,
        'fat': 0.3,
        'carbs': 28.0,
        'fiber': 0.4,
      },
    },
    {
      'foodId': 'local_bread',
      'label': 'Pan Integral',
      'category': 'grains',
      'categoryLabel': 'Cereales',
      'image': 'https://www.edamam.com/food-img/60e/60e8c37db28e3c237f89814265fc7bf3.jpg',
      'nutrients': {
        'calories': 247.0,
        'protein': 13.0,
        'fat': 3.4,
        'carbs': 41.0,
        'fiber': 7.0,
      },
    },
    {
      'foodId': 'local_pasta',
      'label': 'Pasta',
      'category': 'grains',
      'categoryLabel': 'Cereales',
      'image': 'https://www.edamam.com/food-img/296/296ff2b02ef3822928c3c923e22c7d19.jpg',
      'nutrients': {
        'calories': 131.0,
        'protein': 5.0,
        'fat': 1.1,
        'carbs': 25.0,
        'fiber': 1.8,
      },
    },
    
    // Verduras
    {
      'foodId': 'local_broccoli',
      'label': 'Brócoli',
      'category': 'vegetables',
      'categoryLabel': 'Verduras',
      'image': 'https://www.edamam.com/food-img/c9f/c9f42e37bc0e328b83589c27bb9b04c7.jpg',
      'nutrients': {
        'calories': 34.0,
        'protein': 2.8,
        'fat': 0.4,
        'carbs': 7.0,
        'fiber': 2.6,
      },
    },
    {
      'foodId': 'local_tomato',
      'label': 'Tomate',
      'category': 'vegetables',
      'categoryLabel': 'Verduras',
      'image': 'https://www.edamam.com/food-img/23e/23e727a14f1035bdc2733bb0477efbd2.jpg',
      'nutrients': {
        'calories': 18.0,
        'protein': 0.9,
        'fat': 0.2,
        'carbs': 3.9,
        'fiber': 1.2,
      },
    },
    {
      'foodId': 'local_lettuce',
      'label': 'Lechuga',
      'category': 'vegetables',
      'categoryLabel': 'Verduras',
      'image': 'https://www.edamam.com/food-img/719/71996625d0cb47e197093ecd52c97dc2.jpg',
      'nutrients': {
        'calories': 15.0,
        'protein': 1.4,
        'fat': 0.2,
        'carbs': 2.9,
        'fiber': 1.3,
      },
    },
    
    // Lácteos
    {
      'foodId': 'local_milk',
      'label': 'Leche',
      'category': 'dairy',
      'categoryLabel': 'Lácteos',
      'image': 'https://www.edamam.com/food-img/7c9/7c9962bb62f1e0c6c1f4ba53c37d7e9a.jpg',
      'nutrients': {
        'calories': 61.0,
        'protein': 3.2,
        'fat': 3.3,
        'carbs': 4.8,
        'fiber': 0.0,
      },
    },
    {
      'foodId': 'local_yogurt',
      'label': 'Yogur Natural',
      'category': 'dairy',
      'categoryLabel': 'Lácteos',
      'image': 'https://www.edamam.com/food-img/933/933c2a0b23028a9c693d1704d5dd8da8.jpg',
      'nutrients': {
        'calories': 59.0,
        'protein': 3.5,
        'fat': 3.3,
        'carbs': 4.7,
        'fiber': 0.0,
      },
    },
    {
      'foodId': 'local_cheese',
      'label': 'Queso',
      'category': 'dairy',
      'categoryLabel': 'Lácteos',
      'image': 'https://www.edamam.com/food-img/bcd/bcd94dde1fcde1475b5bf0540a0b6d0b.jpg',
      'nutrients': {
        'calories': 402.0,
        'protein': 25.0,
        'fat': 33.0,
        'carbs': 1.3,
        'fiber': 0.0,
      },
    },
    
    // Otros
    {
      'foodId': 'local_avocado',
      'label': 'Aguacate',
      'category': 'fruit',
      'categoryLabel': 'Frutas',
      'image': 'https://www.edamam.com/food-img/984/984a2ab92c0ba6bf5c2d0c0071c13b34.jpg',
      'nutrients': {
        'calories': 160.0,
        'protein': 2.0,
        'fat': 15.0,
        'carbs': 9.0,
        'fiber': 7.0,
      },
    },
    {
      'foodId': 'local_almonds',
      'label': 'Almendras',
      'category': 'nuts',
      'categoryLabel': 'Frutos Secos',
      'image': 'https://www.edamam.com/food-img/6c2/6c2dc21adf11afc4c8d390ee2f651e56.jpg',
      'nutrients': {
        'calories': 579.0,
        'protein': 21.0,
        'fat': 50.0,
        'carbs': 22.0,
        'fiber': 12.0,
      },
    },
    {
      'foodId': 'local_oats',
      'label': 'Avena',
      'category': 'grains',
      'categoryLabel': 'Cereales',
      'image': 'https://www.edamam.com/food-img/e09/e091c7edb96c1c95c91e1e8b96d7c2cb.jpg',
      'nutrients': {
        'calories': 389.0,
        'protein': 17.0,
        'fat': 6.9,
        'carbs': 66.0,
        'fiber': 11.0,
      },
    },
    {
      'foodId': 'local_sweet_potato',
      'label': 'Camote',
      'category': 'vegetables',
      'categoryLabel': 'Verduras',
      'image': 'https://www.edamam.com/food-img/813/813edcc85c6b38a33f5132d75b39aa6f.jpg',
      'nutrients': {
        'calories': 86.0,
        'protein': 1.6,
        'fat': 0.1,
        'carbs': 20.0,
        'fiber': 3.0,
      },
    },
  ];

  /// Buscar alimentos en la base de datos local
  static List<Map<String, dynamic>> search(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase().trim();
    
    return foods.where((food) {
      final label = (food['label'] as String).toLowerCase();
      final category = (food['categoryLabel'] as String).toLowerCase();
      
      return label.contains(lowercaseQuery) || 
             category.contains(lowercaseQuery);
    }).toList();
  }

  /// Obtener todos los alimentos
  static List<Map<String, dynamic>> getAll() => foods;

  /// Obtener alimentos por categoría
  static List<Map<String, dynamic>> getByCategory(String category) {
    return foods.where((food) => food['category'] == category).toList();
  }
}
