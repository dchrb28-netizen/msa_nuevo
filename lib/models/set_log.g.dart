// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetLogAdapter extends TypeAdapter<SetLog> {
  @override
  final int typeId = 17;

  @override
  SetLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetLog(
      reps: fields[0] as int,
      weight: fields[1] as double,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SetLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.reps)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.isCompleted);
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
      reps: (json['reps'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$SetLogToJson(SetLog instance) => <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'isCompleted': instance.isCompleted,
    };
