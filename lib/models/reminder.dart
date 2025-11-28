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
    @HiveField(6) @Default(0) int repeatMinutes, // 0 = no repetir, >0 = repetir cada X minutos
  }) = _Reminder;

  // Añadiendo esta fábrica para intentar desbloquear el generador
  factory Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);
}
