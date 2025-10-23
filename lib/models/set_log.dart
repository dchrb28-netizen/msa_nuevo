import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_log.g.dart';

@JsonSerializable()
@HiveType(typeId: 15)
class SetLog extends HiveObject {
  @HiveField(0)
  final int reps;

  @HiveField(1)
  final double weight;

  @HiveField(2)
  final Duration duration;

  @HiveField(3)
  final String notes;

  SetLog({
    this.reps = 0,
    this.weight = 0.0,
    this.duration = Duration.zero,
    this.notes = '',
  });

  factory SetLog.fromJson(Map<String, dynamic> json) => _$SetLogFromJson(json);
  Map<String, dynamic> toJson() => _$SetLogToJson(this);
}
