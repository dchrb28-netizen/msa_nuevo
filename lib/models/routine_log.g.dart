// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutineLog _$RoutineLogFromJson(Map<String, dynamic> json) => RoutineLog(
      date: DateTime.parse(json['date'] as String),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoutineLogToJson(RoutineLog instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'exercises': instance.exercises,
    };
