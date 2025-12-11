import 'package:hive/hive.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/meal_type.dart';

part 'daily_meal_plan.g.dart';

@HiveType(typeId: 7)
class DailyMealPlan extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final Map<MealType, List<Food>> meals;

  DailyMealPlan({required this.date, required this.meals});

  // Method to convert the object to a JSON-compatible Map
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'meals': meals.map((key, value) =>
            MapEntry(key.toString().split('.').last, value.map((e) => e.toJson()).toList())),
      };

  // Factory constructor to create an object from a Map
  factory DailyMealPlan.fromJson(Map<String, dynamic> json) => DailyMealPlan(
        date: DateTime.parse(json['date']),
        meals: (json['meals'] as Map<String, dynamic>).map((key, value) => MapEntry(
            MealType.values.firstWhere((e) => e.toString().split('.').last == key),
            (value as List<dynamic>).map((e) => Food.fromJson(e)).toList())),
      );
}
