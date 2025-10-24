import 'package:flutter/material.dart';
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
  final String measurement; // 'reps' or 'time'
  final String? imageUrl;
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
