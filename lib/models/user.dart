import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String gender;

  @HiveField(3)
  int age;

  @HiveField(4)
  double height;

  @HiveField(5)
  double weight;

  @HiveField(6)
  String? profileImagePath;

  @HiveField(7)
  bool isGuest;

  @HiveField(8)
  String activityLevel;

  @HiveField(9)
  double? calorieGoal;

  @HiveField(10)
  double? proteinGoal;

  @HiveField(11)
  double? carbGoal;

  @HiveField(12)
  double? fatGoal;

  @HiveField(13) 
  double? weightGoal;

  @HiveField(14) // New field for the user's diet plan
  String? dietPlan;

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
    this.calorieGoal,
    this.proteinGoal,
    this.carbGoal,
    this.fatGoal,
    this.weightGoal,
    this.dietPlan = 'Mantener', // Default to 'Mantener'
  });

  User copyWith({
    String? id,
    String? name,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? profileImagePath,
    bool? isGuest,
    String? activityLevel,
    double? calorieGoal,
    double? proteinGoal,
    double? carbGoal,
    double? fatGoal,
    double? weightGoal,
    String? dietPlan,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isGuest: isGuest ?? this.isGuest,
      activityLevel: activityLevel ?? this.activityLevel,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbGoal: carbGoal ?? this.carbGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      weightGoal: weightGoal ?? this.weightGoal,
      dietPlan: dietPlan ?? this.dietPlan,
    );
  }
}
