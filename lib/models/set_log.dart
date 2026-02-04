import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_log.g.dart';

@JsonSerializable()
@HiveType(typeId: 17)
class SetLog extends HiveObject {
  @HiveField(0)
  int reps;

  @HiveField(1)
  double weight;

  @HiveField(2)
  bool isCompleted;

  SetLog({int? reps, required this.weight, this.isCompleted = false}) : reps = reps ?? 0;

  factory SetLog.fromJson(Map<String, dynamic> json) => _$SetLogFromJson(json);
  Map<String, dynamic> toJson() => _$SetLogToJson(this);
}
