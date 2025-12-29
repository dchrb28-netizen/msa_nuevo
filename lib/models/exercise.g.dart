// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 16;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as String?,
      muscleGroup: fields[4] as String?,
      equipment: fields[5] as String?,
      measurement: fields[6] as String?,
      imageUrl: fields[7] as String?,
      videoUrl: fields[8] as String?,
      difficulty: fields[9] as String?,
      beginnerSets: fields[10] as String?,
      beginnerReps: fields[11] as String?,
      intermediateSets: fields[12] as String?,
      intermediateReps: fields[13] as String?,
      advancedSets: fields[14] as String?,
      advancedReps: fields[15] as String?,
      recommendations: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.muscleGroup)
      ..writeByte(5)
      ..write(obj.equipment)
      ..writeByte(6)
      ..write(obj.measurement)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.videoUrl)
      ..writeByte(9)
      ..write(obj.difficulty)
      ..writeByte(10)
      ..write(obj.beginnerSets)
      ..writeByte(11)
      ..write(obj.beginnerReps)
      ..writeByte(12)
      ..write(obj.intermediateSets)
      ..writeByte(13)
      ..write(obj.intermediateReps)
      ..writeByte(14)
      ..write(obj.advancedSets)
      ..writeByte(15)
      ..write(obj.advancedReps)
      ..writeByte(16)
      ..write(obj.recommendations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String?,
      muscleGroup: json['muscleGroup'] as String?,
      equipment: json['equipment'] as String?,
      measurement: json['measurement'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      difficulty: json['difficulty'] as String?,
      beginnerSets: json['beginnerSets'] as String?,
      beginnerReps: json['beginnerReps'] as String?,
      intermediateSets: json['intermediateSets'] as String?,
      intermediateReps: json['intermediateReps'] as String?,
      advancedSets: json['advancedSets'] as String?,
      advancedReps: json['advancedReps'] as String?,
      recommendations: json['recommendations'] as String?,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'muscleGroup': instance.muscleGroup,
      'equipment': instance.equipment,
      'measurement': instance.measurement,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'difficulty': instance.difficulty,
      'beginnerSets': instance.beginnerSets,
      'beginnerReps': instance.beginnerReps,
      'intermediateSets': instance.intermediateSets,
      'intermediateReps': instance.intermediateReps,
      'advancedSets': instance.advancedSets,
      'advancedReps': instance.advancedReps,
      'recommendations': instance.recommendations,
    };
