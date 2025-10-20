
import 'package:hive/hive.dart';

part 'user_recipe.g.dart';

@HiveType(typeId: 2)
class UserRecipe extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String? imagePath;

  @HiveField(4)
  late List<String> ingredients;

  @HiveField(5)
  late List<String> steps;

  UserRecipe({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
    required this.ingredients,
    required this.steps,
  });
}
