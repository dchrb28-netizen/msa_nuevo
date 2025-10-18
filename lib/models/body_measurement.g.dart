// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_measurement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyMeasurementAdapter extends TypeAdapter<BodyMeasurement> {
  @override
  final int typeId = 3;

  @override
  BodyMeasurement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyMeasurement(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      weight: fields[2] as double?,
      chest: fields[3] as double?,
      arm: fields[4] as double?,
      waist: fields[5] as double?,
      hips: fields[6] as double?,
      thigh: fields[7] as double?,
      height: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BodyMeasurement obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.chest)
      ..writeByte(4)
      ..write(obj.arm)
      ..writeByte(5)
      ..write(obj.waist)
      ..writeByte(6)
      ..write(obj.hips)
      ..writeByte(7)
      ..write(obj.thigh)
      ..writeByte(8)
      ..write(obj.height);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyMeasurementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
