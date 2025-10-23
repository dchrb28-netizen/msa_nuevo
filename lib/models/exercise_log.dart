import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/set_log.dart';

part 'exercise_log.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 4)
class ExerciseLog extends HiveObject {
  @HiveField(0)
  final Exercise exercise;

  @HiveField(1)
  final List<SetLog> sets;

  @HiveField(2)
  final String notes;

  ExerciseLog({
    required this.exercise,
    required this.sets,
    this.notes = '',
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) => _$ExerciseLogFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseLogToJson(this);
}
