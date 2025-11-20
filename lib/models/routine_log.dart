import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/models/exercise_log.dart';

part 'routine_log.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 8)
class RoutineLog extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String routineName;

  @HiveField(2)
  List<ExerciseLog> exerciseLogs;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  int durationInMinutes; // Cambiado de Duration? a int

  RoutineLog({
    required this.date,
    required this.routineName,
    required this.exerciseLogs,
    required this.durationInMinutes, // Añadido como requerido
    this.notes,
  });

  factory RoutineLog.fromJson(Map<String, dynamic> json) =>
      _$RoutineLogFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineLogToJson(this);
}
