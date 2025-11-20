import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

@freezed
@HiveType(typeId: 12)
class Reminder with _$Reminder {
  const factory Reminder({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required int hour,
    @HiveField(3) required int minute,
    @HiveField(4) required List<bool> days,
    @HiveField(5) @Default(true) bool isActive,
  }) = _Reminder;
}
