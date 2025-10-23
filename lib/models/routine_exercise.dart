
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/models/exercise.dart';

part 'routine_exercise.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 7)
class RoutineExercise extends HiveObject {
  @HiveField(0)
  final Exercise exercise;

  @HiveField(1)
  int sets;

  @HiveField(2)
  String reps;

  @HiveField(3)
  double? weight;

  @HiveField(4)
  int? restTime; // in seconds

  RoutineExercise({
    required this.exercise,
    required this.sets,
    required this.reps,
    this.weight,
    this.restTime,
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) => _$RoutineExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineExerciseToJson(this);
}
