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
    return Recipe(
      title: json['title'] ?? 'Sin tÃtulo',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? 'No hay descripciÃ³n disponible.',
      imageUrl: json['imageUrl'],
      isFavorite: json['isFavorite'] ?? false,
      ingredients: (json['ingredients'] as List<dynamic>? ?? []).map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList(),
      instructions: List<String>.from(json['instructions'] ?? []),
      nutrients: (json['nutrients'] as List<dynamic>? ?? []).map((e) => Nutrient.fromJson(e as Map<String, dynamic>)).toList(),
      prepTime: json['prepTime'],
      cookTime: json['cookTime'],
      totalTime: json['totalTime'],
      servings: json['servings'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'link': link,
    'snippet': snippet,
    'imageUrl': imageUrl,
    'isFavorite': isFavorite,
    'ingredients': ingredients.map((e) => e.toJson()).toList(),
    'instructions': instructions,
    'nutrients': nutrients.map((e) => e.toJson()).toList(),
    'prepTime': prepTime,
    'cookTime': cookTime,
    'totalTime': totalTime,
    'servings': servings,
  };
}

@HiveType(typeId: 11)
class Ingredient extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String quantity;

  Ingredient({required this.name, required this.quantity});

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    name: json['name'],
    quantity: json['quantity'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
  };
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

  factory Nutrient.fromJson(Map<String, dynamic> json) => Nutrient(
    name: json['name'],
    amount: json['amount'],
    unit: json['unit'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'unit': unit,
  };
}
