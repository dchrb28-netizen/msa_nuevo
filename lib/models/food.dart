import 'package:hive/hive.dart';

part 'food.g.dart';

@HiveType(typeId: 4)
class Food extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double calories;

  @HiveField(3)
  late double proteins;

  @HiveField(4)
  late double carbohydrates;

  @HiveField(5)
  late double fats;

  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbohydrates,
    required this.fats,
  });
}
