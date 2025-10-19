// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetLog _$SetLogFromJson(Map<String, dynamic> json) => SetLog(
      reps: (json['reps'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      time: json['time'] == null
          ? null
          : Duration(microseconds: (json['time'] as num).toInt()),
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SetLogToJson(SetLog instance) => <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'time': instance.time?.inMicroseconds,
      'distance': instance.distance,
    };
