import 'package:hive/hive.dart';

part 'water_log.g.dart';

@HiveType(typeId: 0)
class WaterLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime timestamp;

  WaterLog({required this.id, required this.amount, required this.timestamp});
}
