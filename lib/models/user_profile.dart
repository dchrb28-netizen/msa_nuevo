// No Hive annotations. This is now a Plain Old Dart Object (POJO).
class UserProfile {
  int experiencePoints;
  int level;
  Map<String, DateTime> unlockedAchievements;
  String? selectedTitle;
  Map<String, int> achievementProgress;

  UserProfile({
    this.experiencePoints = 0,
    this.level = 1,
    Map<String, DateTime>? unlockedAchievements,
    this.selectedTitle,
    Map<String, int>? achievementProgress,
  })  : unlockedAchievements = unlockedAchievements ?? {},
        achievementProgress = achievementProgress ?? {};

  int get currentLevel => level;
  int get currentXp => experiencePoints;

  int get nextLevelXp {
    final lvl = currentLevel;
    return (lvl * (lvl + 1) * 50) + 100;
  }

  double get levelProgressPercentage {
    final lvl = currentLevel;
    final xp = currentXp;

    final currentLevelXp = (lvl > 1) ? ((lvl - 1) * lvl * 50) + 100 : 0;
    final xpInCurrentLevel = xp - currentLevelXp;
    final xpForNextLevel = nextLevelXp - currentLevelXp;

    if (xpForNextLevel <= 0) return 1.0; 

    return (xpInCurrentLevel / xpForNextLevel).clamp(0.0, 1.0);
  }

  // Method to convert the object to a JSON-compatible Map
  Map<String, dynamic> toJson() => {
        'experiencePoints': experiencePoints,
        'level': level,
        'unlockedAchievements': unlockedAchievements
            .map((key, value) => MapEntry(key, value.toIso8601String())),
        'selectedTitle': selectedTitle,
        'achievementProgress': achievementProgress,
      };

  // Factory constructor to create an object from a Map
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        experiencePoints: json['experiencePoints'] ?? 0,
        level: json['level'] ?? 1,
        unlockedAchievements: json['unlockedAchievements'] != null
            ? Map<String, DateTime>.from(json['unlockedAchievements']
                .map((key, value) => MapEntry(key, DateTime.parse(value))))
            : {},
        selectedTitle: json['selectedTitle'],
        achievementProgress: json['achievementProgress'] != null
            ? Map<String, int>.from(json['achievementProgress'])
            : {},
      );
}
