import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

@HiveType(typeId: 16)
@JsonSerializable()
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String? type;
  @HiveField(4)
  final String? muscleGroup;
  @HiveField(5)
  final String? equipment;
  @HiveField(6)
  final String? measurement; // 'reps' or 'time'
  @HiveField(7)
  final String? imageUrl;
  @HiveField(8)
  final String? videoUrl;

  @HiveField(9)
  final String? difficulty; // Principiante, Intermedio, Avanzado

  // Recommendations
  @HiveField(10)
  final String? beginnerSets;
  @HiveField(11)
  final String? beginnerReps;

  @HiveField(12)
  final String? intermediateSets;
  @HiveField(13)
  final String? intermediateReps;

  @HiveField(14)
  final String? advancedSets;
  @HiveField(15)
  final String? advancedReps;

  @HiveField(16)
  final String? recommendations;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.muscleGroup,
    this.equipment,
    this.measurement,
    this.imageUrl,
    this.videoUrl,
    this.difficulty,
    this.beginnerSets,
    this.beginnerReps,
    this.intermediateSets,
    this.intermediateReps,
    this.advancedSets,
    this.advancedReps,
    this.recommendations,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
