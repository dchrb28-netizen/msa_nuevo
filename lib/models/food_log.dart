import 'package:hive/hive.dart';

part 'food_log.g.dart';

@HiveType(typeId: 1)
class FoodLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String foodName;

  @HiveField(2)
  final double calories;

  @HiveField(3)
  final double protein;

  @HiveField(4)
  final double carbohydrates;

  @HiveField(5)
  final double fat;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String mealType;

  FoodLog({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.date,
    required this.mealType,
  });
}
