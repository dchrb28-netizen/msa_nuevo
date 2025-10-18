import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String gender;

  @HiveField(3)
  final int age;

  @HiveField(4)
  final double height;

  @HiveField(5)
  final double weight;

  @HiveField(6)
  final String? profileImagePath;

  @HiveField(7)
  final bool isGuest;

  @HiveField(8)
  final String activityLevel;

  User({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    this.profileImagePath,
    this.isGuest = false,
    this.activityLevel = 'Sedentaria',
  });
}
