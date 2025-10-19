import 'package:json_annotation/json_annotation.dart';

part 'set_log.g.dart';

@JsonSerializable()
class SetLog {
  final int? reps;
  final double? weight;
  final Duration? time;
  final double? distance;

  SetLog({this.reps, this.weight, this.time, this.distance});

  factory SetLog.fromJson(Map<String, dynamic> json) => _$SetLogFromJson(json);
  Map<String, dynamic> toJson() => _$SetLogToJson(this);

  @override
  String toString() {
    final parts = <String>[];
    if (reps != null) parts.add('$reps reps');
    if (weight != null) parts.add('$weight kg');
    if (time != null) parts.add('${time!.inMinutes} min');
    if (distance != null) parts.add('$distance km');
    return parts.join(' - ');
  }
}
