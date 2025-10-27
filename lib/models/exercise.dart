import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

@HiveType(typeId: 16)
@JsonSerializable()
class Exercise {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String type;
  @HiveField(4)
  final String muscleGroup;
  @HiveField(5)
  final String equipment;
  @HiveField(6)
  final String measurement; // 'reps' or 'time'
  @HiveField(7)
  final String? imageUrl;
  @HiveField(8)
  final String? videoUrl;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final IconData? icon;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.muscleGroup,
    required this.equipment,
    required this.measurement,
    this.imageUrl,
    this.videoUrl,
    this.icon,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
