import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'food.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class Food extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  double? calories;

  @HiveField(3)
  double? proteins;

  @HiveField(4)
  double? carbohydrates;

  @HiveField(5)
  double? fats;

  Food({
    required this.id,
    required this.name,
    this.calories,
    this.proteins,
    this.carbohydrates,
    this.fats,
  });

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);

  Map<String, dynamic> toJson() => _$FoodToJson(this);
}
