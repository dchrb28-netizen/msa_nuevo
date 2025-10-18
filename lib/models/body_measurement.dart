import 'package:hive/hive.dart';

part 'body_measurement.g.dart';

@HiveType(typeId: 3)
class BodyMeasurement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final double? weight;

  @HiveField(3)
  final double? chest;

  @HiveField(4)
  final double? arm;

  @HiveField(5)
  final double? waist;

  @HiveField(6)
  final double? hips;

  @HiveField(7)
  final double? thigh;

  @HiveField(8)
  final double? height;

  BodyMeasurement({
    required this.id,
    required this.timestamp,
    this.weight,
    this.chest,
    this.arm,
    this.waist,
    this.hips,
    this.thigh,
    this.height,
  });
}
