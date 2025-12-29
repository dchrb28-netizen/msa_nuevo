// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealPlanTemplateAdapter extends TypeAdapter<MealPlanTemplate> {
  @override
  final int typeId = 20;

  @override
  MealPlanTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealPlanTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      goalType: fields[3] as String,
      dailyCalories: fields[4] as int,
      weekMenu: (fields[5] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<MealSuggestion>())),
      estimatedCostPerDay: fields[6] as double?,
      costLevel: fields[7] as String?,
      tags: (fields[8] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MealPlanTemplate obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.goalType)
      ..writeByte(4)
      ..write(obj.dailyCalories)
      ..writeByte(5)
      ..write(obj.weekMenu)
      ..writeByte(6)
      ..write(obj.estimatedCostPerDay)
      ..writeByte(7)
      ..write(obj.costLevel)
      ..writeByte(8)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlanTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealSuggestionAdapter extends TypeAdapter<MealSuggestion> {
  @override
  final int typeId = 21;

  @override
  MealSuggestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealSuggestion(
      mealType: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      calories: fields[3] as int?,
      estimatedCost: fields[4] as double?,
      affordableAlternatives: (fields[5] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MealSuggestion obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.mealType)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.estimatedCost)
      ..writeByte(5)
      ..write(obj.affordableAlternatives);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealSuggestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
