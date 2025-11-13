
import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 12) // New unique typeId
class Reminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int hour;

  @HiveField(3)
  int minute;

  @HiveField(4)
  List<bool> days;

  @HiveField(5)
  bool isActive;

  Reminder({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    required this.days,
    this.isActive = true,
  });

  Reminder copyWith({
    String? id,
    String? title,
    int? hour,
    int? minute,
    List<bool>? days,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
    );
  }
}
