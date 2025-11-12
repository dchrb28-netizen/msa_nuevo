
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_recipe.g.dart';

@HiveType(typeId: 2)
class UserRecipe extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final List<String> ingredients;

  @HiveField(4)
  final List<String> instructions;

  @HiveField(5)
  final Uint8List? imageBytes; 
  
  @HiveField(6)
  final String? category;

  @HiveField(7)
  final int? cookingTime; // in minutes

  @HiveField(8)
  final int? servings;

  @HiveField(9)
  bool isFavorite;


  UserRecipe({
    required this.title,
    this.description,
    required this.ingredients,
    required this.instructions,
    this.imageBytes,
    this.category,
    this.cookingTime,
    this.servings,
    this.isFavorite = false,
  }) {
    id = const Uuid().v4();
  }
}
