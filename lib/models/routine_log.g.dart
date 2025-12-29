// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineLogAdapter extends TypeAdapter<RoutineLog> {
  @override
  final int typeId = 8;

  @override
  RoutineLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineLog(
      date: fields[0] as DateTime,
      routineName: fields[1] as String,
      exerciseLogs: (fields[2] as List).cast<ExerciseLog>(),
      durationInMinutes: fields[4] as int,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.routineName)
      ..writeByte(2)
      ..write(obj.exerciseLogs)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.durationInMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
