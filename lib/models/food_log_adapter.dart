import 'package:hive/hive.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/food_log.dart';

class FoodLogAdapter extends TypeAdapter<FoodLog> {
  @override
  final int typeId = 2; // Unique ID for this adapter

  @override
  FoodLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodLog(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      mealType: fields[2] as String,
      food: fields[3] as Food, 
      quantity: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FoodLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.food)
      ..writeByte(4)
      ..write(obj.quantity);
  }
}
