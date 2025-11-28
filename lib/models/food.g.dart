// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodAdapter extends TypeAdapter<Food> {
  @override
  final int typeId = 4;

  @override
  Food read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Food(
      id: fields[0] as String,
      name: fields[1] as String,
      calories: fields[2] as double?,
      proteins: fields[3] as double?,
      carbohydrates: fields[4] as double?,
      fats: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Food obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.proteins)
      ..writeByte(4)
      ..write(obj.carbohydrates)
      ..writeByte(5)
      ..write(obj.fats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Food _$FoodFromJson(Map<String, dynamic> json) => Food(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: (json['calories'] as num?)?.toDouble(),
      proteins: (json['proteins'] as num?)?.toDouble(),
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
      fats: (json['fats'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FoodToJson(Food instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'calories': instance.calories,
      'proteins': instance.proteins,
      'carbohydrates': instance.carbohydrates,
      'fats': instance.fats,
    };
