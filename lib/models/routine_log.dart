import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/models/exercise_log.dart';

part 'routine_log.g.dart';

@JsonSerializable()
class RoutineLog {
  final DateTime date;
  final List<ExerciseLog> exercises;

  RoutineLog({required this.date, required this.exercises});

  factory RoutineLog.fromJson(Map<String, dynamic> json) => _$RoutineLogFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineLogToJson(this);
}
