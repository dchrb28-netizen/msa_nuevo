import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/models/exercise.dart';

part 'routine.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 13)
class Routine extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  @JsonKey(name: 'exercises') // Asegúrate de que el nombre coincida con el JSON
  List<Exercise> exercises;

  Routine({
    required this.id,
    required this.name,
    this.description = '',
    required this.exercises,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineToJson(this);
}
