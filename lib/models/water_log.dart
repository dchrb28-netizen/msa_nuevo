import 'package:hive/hive.dart';

part 'water_log.g.dart';

@HiveType(typeId: 2)
class WaterLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double amount; // Changed to be non-final

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3) // Added userId
  final String userId;

  WaterLog({required this.id, required this.amount, required this.timestamp, required this.userId});
}
