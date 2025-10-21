// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FastingLogAdapter extends TypeAdapter<FastingLog> {
  @override
  final int typeId = 14;

  @override
  FastingLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FastingLog(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FastingLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.durationInSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastingLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
