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

  // Method to convert the object to a JSON-compatible Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'weight': weight,
      'chest': chest,
      'arm': arm,
      'waist': waist,
      'hips': hips,
      'thigh': thigh,
      'height': height,
    };
  }

  // Factory constructor to create an object from a Map
  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      weight: json['weight']?.toDouble(),
      chest: json['chest']?.toDouble(),
      arm: json['arm']?.toDouble(),
      waist: json['waist']?.toDouble(),
      hips: json['hips']?.toDouble(),
      thigh: json['thigh']?.toDouble(),
      height: json['height']?.toDouble(),
    );
  }
}
