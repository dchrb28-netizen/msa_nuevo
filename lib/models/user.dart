import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:myapp/models/recipe.dart';

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
  Uint8List? profileImageBytes;

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

  @HiveField(14) 
  String? dietPlan;

  @HiveField(15)
  double? waterGoal;
  
  @HiveField(16)
  List<Recipe> favoriteRecipes;

  @HiveField(17)
  double? initialWeight; // Nuevo campo para el peso inicial

  User({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    this.profileImageBytes,
    this.isGuest = false,
    this.activityLevel = 'Sedentaria',
    this.calorieGoal,
    this.proteinGoal,
    this.carbGoal,
    this.fatGoal,
    this.weightGoal,
    this.dietPlan = 'Mantener',
    this.waterGoal,
    List<Recipe>? favoriteRecipes,
    this.initialWeight, // Añadido al constructor
  }) : favoriteRecipes = favoriteRecipes ?? [];

  User copyWith({
    String? id,
    String? name,
    String? gender,
    int? age,
    double? height,
    double? weight,
    Uint8List? profileImageBytes,
    bool? isGuest,
    String? activityLevel,
    double? calorieGoal,
    double? proteinGoal,
    double? carbGoal,
    double? fatGoal,
    double? weightGoal,
    String? dietPlan,
    double? waterGoal,
    List<Recipe>? favoriteRecipes,
    double? initialWeight, // Añadido a copyWith
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
      isGuest: isGuest ?? this.isGuest,
      activityLevel: activityLevel ?? this.activityLevel,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbGoal: carbGoal ?? this.carbGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      weightGoal: weightGoal ?? this.weightGoal,
      dietPlan: dietPlan ?? this.dietPlan,
      waterGoal: waterGoal ?? this.waterGoal,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      initialWeight: initialWeight ?? this.initialWeight, // Añadido a copyWith
    );
  }
}
