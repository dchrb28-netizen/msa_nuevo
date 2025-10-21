import 'package:hive/hive.dart';

part 'fasting_log.g.dart';

@HiveType(typeId: 14) // Siguiente typeId disponible
class FastingLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  int get durationInSeconds {
    if (endTime == null) {
      return DateTime.now().difference(startTime).inSeconds;
    }
    return endTime!.difference(startTime).inSeconds;
  }

  FastingLog({
    required this.id,
    required this.startTime,
    this.endTime,
  });
}
