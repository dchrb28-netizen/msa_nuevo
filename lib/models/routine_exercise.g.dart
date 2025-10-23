// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineExerciseAdapter extends TypeAdapter<RoutineExercise> {
  @override
  final int typeId = 7;

  @override
  RoutineExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineExercise(
      exercise: fields[0] as Exercise,
      sets: fields[1] as int,
      reps: fields[2] as String,
      weight: fields[3] as double?,
      restTime: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineExercise obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.exercise)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.restTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutineExercise _$RoutineExerciseFromJson(Map<String, dynamic> json) =>
    RoutineExercise(
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: (json['sets'] as num).toInt(),
      reps: json['reps'] as String,
      weight: (json['weight'] as num?)?.toDouble(),
      restTime: (json['restTime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RoutineExerciseToJson(RoutineExercise instance) =>
    <String, dynamic>{
      'exercise': instance.exercise.toJson(),
      'sets': instance.sets,
      'reps': instance.reps,
      'weight': instance.weight,
      'restTime': instance.restTime,
    };
