// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_meal_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyMealPlanAdapter extends TypeAdapter<DailyMealPlan> {
  @override
  final int typeId = 7;

  @override
  DailyMealPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyMealPlan(
      date: fields[0] as DateTime,
      meals: (fields[1] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as MealType, (v as List).cast<Food>())),
    );
  }

  @override
  void write(BinaryWriter writer, DailyMealPlan obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.meals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyMealPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
