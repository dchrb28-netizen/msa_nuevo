// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      gender: fields[2] as String,
      age: fields[3] as int,
      height: fields[4] as double,
      weight: fields[5] as double,
      profileImageBytes: fields[6] as Uint8List?,
      isGuest: fields[7] as bool,
      activityLevel: fields[8] as String,
      calorieGoal: fields[9] as double?,
      proteinGoal: fields[10] as double?,
      carbGoal: fields[11] as double?,
      fatGoal: fields[12] as double?,
      weightGoal: fields[13] as double?,
      dietPlan: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.height)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.profileImageBytes)
      ..writeByte(7)
      ..write(obj.isGuest)
      ..writeByte(8)
      ..write(obj.activityLevel)
      ..writeByte(9)
      ..write(obj.calorieGoal)
      ..writeByte(10)
      ..write(obj.proteinGoal)
      ..writeByte(11)
      ..write(obj.carbGoal)
      ..writeByte(12)
      ..write(obj.fatGoal)
      ..writeByte(13)
      ..write(obj.weightGoal)
      ..writeByte(14)
      ..write(obj.dietPlan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
