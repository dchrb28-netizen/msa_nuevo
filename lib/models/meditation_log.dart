import 'package:hive/hive.dart';

part 'meditation_log.g.dart';

@HiveType(typeId: 12)
class MeditationLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final int durationInSeconds;

  MeditationLog({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationInSeconds,
  });
}
