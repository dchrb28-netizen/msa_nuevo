import 'package:hive/hive.dart';

part 'sleep_log.g.dart';

@HiveType(typeId: 10)
class SleepLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final Duration duration;

  @HiveField(4)
  final int quality;

  SleepLog({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.quality,
  });
}
