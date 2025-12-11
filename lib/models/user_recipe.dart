import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_recipe.g.dart';

@HiveType(typeId: 19) // Changed to 19 to avoid conflict with RoutineExercise (typeId: 18)
class UserRecipe {
  @HiveField(0)
  String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final List<String> ingredients;

  @HiveField(4)
  final List<String> instructions;

  @HiveField(5)
  final List<int>? imageBytes;

  @HiveField(6)
  final String? category;

  @HiveField(7)
  final double? cookingTime; // in minutes

  @HiveField(8)
  final double? servings;

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
  }) : id = const Uuid().v4();
}
