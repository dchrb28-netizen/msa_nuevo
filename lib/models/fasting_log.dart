import 'package:hive/hive.dart';

part 'fasting_log.g.dart';

@HiveType(typeId: 14)
class FastingLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(4)
  String? notes;

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
    this.notes,
  });

  // toJson method
  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'notes': notes,
      };

  // fromJson factory
  factory FastingLog.fromJson(Map<String, dynamic> json) {
    return FastingLog(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      notes: json['notes'],
    );
  }
}
