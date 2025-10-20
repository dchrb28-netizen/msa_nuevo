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
}
