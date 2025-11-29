import 'package:hive/hive.dart';

part 'meal_entry.g.dart';

@HiveType(typeId: 11) // New typeId for MealEntry
class MealEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String foodId; // Reference to the Food object

  @HiveField(2)
  final double amountGrams;

  @HiveField(3)
  final String mealType; // e.g., 'Breakfast', 'Lunch', 'Dinner', 'Snack'

  @HiveField(4)
  final DateTime timestamp;

  MealEntry({
    required this.id,
    required this.foodId,
    required this.amountGrams,
    required this.mealType,
    required this.timestamp,
  });

  // toJson method
  Map<String, dynamic> toJson() => {
        'id': id,
        'foodId': foodId,
        'amountGrams': amountGrams,
        'mealType': mealType,
        'timestamp': timestamp.toIso8601String(),
      };

  // fromJson factory
  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'],
      foodId: json['foodId'],
      amountGrams: json['amountGrams'],
      mealType: json['mealType'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
