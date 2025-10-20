// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserRecipeAdapter extends TypeAdapter<UserRecipe> {
  @override
  final int typeId = 2;

  @override
  UserRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserRecipe(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      imagePath: fields[3] as String?,
      ingredients: (fields[4] as List).cast<String>(),
      steps: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserRecipe obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.steps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
