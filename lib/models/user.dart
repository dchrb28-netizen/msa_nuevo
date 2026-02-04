import 'dart:convert';
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
  double? initialWeight;

  @HiveField(18)
  String? level;

  @HiveField(19)
  bool? showProfileFrame; // Puede ser nulo para retrocompatibilidad

  @HiveField(20)
  String? goal; // Objetivo del usuario (Pérdida de peso, Ganancia muscular, etc.)

  @HiveField(21)
  String? dietaryPreferences; // Preferencias dietéticas (Vegano, Keto, etc.)

  @HiveField(22)
  List<String> favoriteRawFoods; // Alimentos que le encantan (pollo, salmón, etc.)

  @HiveField(23)
  List<String> dislikedFoods; // Alimentos que no le gustan

  @HiveField(24)
  List<String> allergens; // Alergias/Intolerancias

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
    this.initialWeight,
    this.level,
    this.showProfileFrame,
    this.goal,
    this.dietaryPreferences,
    List<String>? favoriteRawFoods,
    List<String>? dislikedFoods,
    List<String>? allergens,
  }) : favoriteRecipes = favoriteRecipes ?? [],
       favoriteRawFoods = favoriteRawFoods ?? [],
       dislikedFoods = dislikedFoods ?? [],
       allergens = allergens ?? [];

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
    double? initialWeight,
    String? level,
    bool? showProfileFrame,
    String? goal,
    String? dietaryPreferences,
    List<String>? favoriteRawFoods,
    List<String>? dislikedFoods,
    List<String>? allergens,
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
      initialWeight: initialWeight ?? this.initialWeight,
      level: level ?? this.level,
      showProfileFrame: showProfileFrame ?? this.showProfileFrame,
      goal: goal ?? this.goal,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      favoriteRawFoods: favoriteRawFoods ?? this.favoriteRawFoods,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      allergens: allergens ?? this.allergens,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'age': age,
        'height': height,
        'weight': weight,
        'profileImageBytes':
            profileImageBytes != null ? base64Encode(profileImageBytes!) : null,
        'isGuest': isGuest,
        'activityLevel': activityLevel,
        'calorieGoal': calorieGoal,
        'proteinGoal': proteinGoal,
        'carbGoal': carbGoal,
        'fatGoal': fatGoal,
        'weightGoal': weightGoal,
        'dietPlan': dietPlan,
        'waterGoal': waterGoal,
        'favoriteRecipes': favoriteRecipes.map((e) => e.toJson()).toList(),
        'initialWeight': initialWeight,
        'level': level,
        'showProfileFrame': showProfileFrame,
        'goal': goal,
        'dietaryPreferences': dietaryPreferences,
        'favoriteRawFoods': favoriteRawFoods,
        'dislikedFoods': dislikedFoods,
        'allergens': allergens,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        gender: json['gender'],
        age: json['age'],
        height: json['height'],
        weight: json['weight'],
        profileImageBytes: json['profileImageBytes'] != null
            ? base64Decode(json['profileImageBytes'])
            : null,
        isGuest: json['isGuest'] ?? false,
        activityLevel: json['activityLevel'] ?? 'Sedentaria', // FIX
        calorieGoal: json['calorieGoal']?.toDouble(),
        proteinGoal: json['proteinGoal']?.toDouble(),
        carbGoal: json['carbGoal']?.toDouble(),
        fatGoal: json['fatGoal']?.toDouble(),
        weightGoal: json['weightGoal']?.toDouble(),
        dietPlan: json['dietPlan'] ?? 'Mantener', // FIX
        waterGoal: json['waterGoal']?.toDouble(),
        favoriteRecipes: json['favoriteRecipes'] != null
            ? List<Recipe>.from(json['favoriteRecipes'].map((x) => Recipe.fromJson(x)))
            : [],
        initialWeight: json['initialWeight']?.toDouble(),
        level: json['level'],
        showProfileFrame: json['showProfileFrame'],
        goal: json['goal'],
        dietaryPreferences: json['dietaryPreferences'],
        favoriteRawFoods: json['favoriteRawFoods'] != null
            ? List<String>.from(json['favoriteRawFoods'])
            : [],
        dislikedFoods: json['dislikedFoods'] != null
            ? List<String>.from(json['dislikedFoods'])
            : [],
        allergens: json['allergens'] != null ? List<String>.from(json['allergens']) : [],
      );
}
