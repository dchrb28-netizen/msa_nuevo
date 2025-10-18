import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

@JsonSerializable()
class Exercise {
  final String id;
  final String name;
  final String description;
  final String type;
  final String muscleGroup;
  final String equipment;
  final String? imageUrl;
  final String? videoUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.muscleGroup,
    required this.equipment,
    this.imageUrl,
    this.videoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
