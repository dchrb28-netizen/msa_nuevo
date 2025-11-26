// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutineLog _$RoutineLogFromJson(Map<String, dynamic> json) => RoutineLog(
      date: DateTime.parse(json['date'] as String),
      routineName: json['routineName'] as String,
      exerciseLogs: (json['exerciseLogs'] as List<dynamic>)
          .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      durationInMinutes: (json['durationInMinutes'] as num).toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$RoutineLogToJson(RoutineLog instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'routineName': instance.routineName,
      'exerciseLogs': instance.exerciseLogs.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'durationInMinutes': instance.durationInMinutes,
    };
