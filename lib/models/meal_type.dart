import 'package:hive/hive.dart';

part 'meal_type.g.dart';

@HiveType(typeId: 6)
enum MealType {
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snacks,
}
