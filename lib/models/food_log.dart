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

  // Method to convert the object to a JSON-compatible Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'foodName': foodName,
        'calories': calories,
        'protein': protein,
        'carbohydrates': carbohydrates,
        'fat': fat,
        'date': date.toIso8601String(),
        'mealType': mealType,
      };

  // Factory constructor to create an object from a Map
  factory FoodLog.fromJson(Map<String, dynamic> json) => FoodLog(
        id: json['id'],
        foodName: json['foodName'],
        calories: json['calories'].toDouble(),
        protein: json['protein'].toDouble(),
        carbohydrates: json['carbohydrates'].toDouble(),
        fat: json['fat'].toDouble(),
        date: DateTime.parse(json['date']),
        mealType: json['mealType'],
      );
}
