// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_week_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealWeekPlanAdapter extends TypeAdapter<MealWeekPlan> {
  @override
  final int typeId = 30;

  @override
  MealWeekPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealWeekPlan(
      weekPlan: (fields[0] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as int, (v as Map).cast<String, MealPlanEntry>())),
    );
  }

  @override
  void write(BinaryWriter writer, MealWeekPlan obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.weekPlan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealWeekPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealPlanEntryAdapter extends TypeAdapter<MealPlanEntry> {
  @override
  final int typeId = 31;

  @override
  MealPlanEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealPlanEntry(
      description: fields[0] as String,
      details: fields[1] as String?,
      calories: fields[2] as int?,
      isCompleted: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MealPlanEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.details)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlanEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
