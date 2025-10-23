// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetLogAdapter extends TypeAdapter<SetLog> {
  @override
  final int typeId = 15;

  @override
  SetLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetLog(
      reps: fields[0] as int,
      weight: fields[1] as double,
      duration: fields[2] as Duration,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SetLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.reps)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetLog _$SetLogFromJson(Map<String, dynamic> json) => SetLog(
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['duration'] as num).toInt()),
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$SetLogToJson(SetLog instance) => <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'duration': instance.duration.inMicroseconds,
      'notes': instance.notes,
    };
