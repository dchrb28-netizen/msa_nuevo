// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetLog _$SetLogFromJson(Map<String, dynamic> json) => SetLog(
      reps: (json['reps'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$SetLogToJson(SetLog instance) => <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'isCompleted': instance.isCompleted,
    };
