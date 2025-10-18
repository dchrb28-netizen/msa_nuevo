import 'package:hive/hive.dart';
import 'package:myapp/models/food.dart';

part 'food_log.g.dart';

@HiveType(typeId: 2)
class FoodLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String mealType;

  @HiveField(3)
  final Food food;

  @HiveField(4)
  final double quantity;

  FoodLog({
    required this.id,
    required this.timestamp,
    required this.mealType,
    required this.food,
    required this.quantity,
  });
}
