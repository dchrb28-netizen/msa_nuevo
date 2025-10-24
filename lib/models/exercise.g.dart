// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      muscleGroup: json['muscleGroup'] as String,
      equipment: json['equipment'] as String,
      measurement: json['measurement'] as String,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'muscleGroup': instance.muscleGroup,
      'equipment': instance.equipment,
      'measurement': instance.measurement,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
    };
