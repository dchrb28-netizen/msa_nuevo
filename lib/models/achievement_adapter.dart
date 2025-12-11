import 'package:hive/hive.dart';
import 'package:myapp/models/achievement.dart';
import 'package:flutter/material.dart';

// Nota: IconData no puede ser const aquí porque se lee dinámicamente de Hive
// Requiere: flutter build appbundle --release --no-tree-shake-icons

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 20;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      icon: IconData(fields[3] as int, fontFamily: 'MaterialIcons'),
      category: AchievementCategory.values[fields[4] as int],
      goal: fields[5] as int,
      unit: fields[6] as String,
      isUnlocked: fields[7] as bool,
      unlockedDate: fields[8] as DateTime?,
      progress: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon.codePoint)
      ..writeByte(4)
      ..write(obj.category.index)
      ..writeByte(5)
      ..write(obj.goal)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.isUnlocked)
      ..writeByte(8)
      ..write(obj.unlockedDate)
      ..writeByte(9)
      ..write(obj.progress);
  }
}
