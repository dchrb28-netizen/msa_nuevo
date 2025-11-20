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
}
