import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/models/set_log.dart';

part 'exercise_log.g.dart';

@JsonSerializable()
class ExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final List<SetLog> sets;

  ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    this.sets = const [],
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) => _$ExerciseLogFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseLogToJson(this);
}
