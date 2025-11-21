import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 10)
class Recipe extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String link;

  @HiveField(2)
  String snippet;

  @HiveField(3)
  String? imageUrl;

  @HiveField(4)
  bool isFavorite;

  @HiveField(5)
  List<Ingredient> ingredients;

  @HiveField(6)
  List<String> instructions;

  @HiveField(7)
  List<Nutrient> nutrients;

  @HiveField(8)
  String? prepTime;

  @HiveField(9)
  String? cookTime;

  @HiveField(10)
  String? totalTime;

  @HiveField(11)
  String? servings;

  Recipe({
    required this.title,
    required this.link,
    required this.snippet,
    this.imageUrl,
    this.isFavorite = false,
    this.ingredients = const [],
    this.instructions = const [],
    this.nutrients = const [],
    this.prepTime,
    this.cookTime,
    this.totalTime,
    this.servings,
  });

  Recipe copyWith({
    String? title,
    String? link,
    String? snippet,
    String? imageUrl,
    bool? isFavorite,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    List<Nutrient>? nutrients,
    String? prepTime,
    String? cookTime,
    String? totalTime,
    String? servings,
  }) {
    return Recipe(
      title: title ?? this.title,
      link: link ?? this.link,
      snippet: snippet ?? this.snippet,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutrients: nutrients ?? this.nutrients,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      totalTime: totalTime ?? this.totalTime,
      servings: servings ?? this.servings,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json.containsKey('pagemap') &&
        json['pagemap'].containsKey('cse_thumbnail') &&
        json['pagemap']['cse_thumbnail'] is List &&
        (json['pagemap']['cse_thumbnail'] as List).isNotEmpty) {
      imageUrl = json['pagemap']['cse_thumbnail'][0]['src'];
    } else if (json.containsKey('pagemap') &&
        json['pagemap'].containsKey('metatags') &&
        json['pagemap']['metatags'] is List &&
        (json['pagemap']['metatags'] as List).isNotEmpty &&
        json['pagemap']['metatags'][0].containsKey('og:image')) {
      imageUrl = json['pagemap']['metatags'][0]['og:image'];
    }

    return Recipe(
      title: json['title'] ?? 'Sin título',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? 'No hay descripción disponible.',
      imageUrl: imageUrl,
      // Los campos complejos como ingredientes, instrucciones, etc., 
      // no se rellenan desde este JSON simple. Requerirían un scraping más avanzado.
    );
  }
}

@HiveType(typeId: 11)
class Ingredient extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String quantity;

  Ingredient({required this.name, required this.quantity});
}

@HiveType(typeId: 12)
class Nutrient extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String amount;

  @HiveField(2)
  final String unit;

  Nutrient({required this.name, required this.amount, required this.unit});
}
