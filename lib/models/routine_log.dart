import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/models/exercise_log.dart';

part 'routine_log.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 14)
class RoutineLog extends HiveObject {
  @HiveField(0)
  final String routineName;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<ExerciseLog> exerciseLogs;

  @HiveField(3)
  final Duration duration;

  @HiveField(4)
  final String notes;

  RoutineLog({
    required this.routineName,
    required this.date,
    required this.exerciseLogs,
    this.duration = Duration.zero,
    this.notes = '',
  });

  factory RoutineLog.fromJson(Map<String, dynamic> json) => _$RoutineLogFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineLogToJson(this);
}
