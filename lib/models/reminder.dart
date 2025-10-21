
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
}
