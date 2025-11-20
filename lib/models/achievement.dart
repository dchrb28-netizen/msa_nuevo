import 'package:flutter/material.dart';

enum AchievementCategory {
  firstSteps('Primeros Pasos'),
  streaks('Rachas Legendarias'),
  cumulative('Hitos Acumulativos'),
  milestones('Metas Personales'),
  exploration('Exploración y Curiosidad');

  const AchievementCategory(this.displayName);
  final String displayName;
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final int totalSteps;
  final String metric; // E.g., 'días', 'litros', 'kg', 'rutinas'

  // Estado del usuario
  bool isUnlocked;
  DateTime? unlockedDate;
  int userProgress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.totalSteps = 1, // Por defecto, un logro se completa en 1 paso
    this.metric = '',
    this.isUnlocked = false,
    this.unlockedDate,
    this.userProgress = 0,
  });

  double get progressPercentage {
    if (totalSteps <= 0) return 0.0;
    if (isUnlocked) return 1.0;
    return (userProgress / totalSteps).clamp(0.0, 1.0);
  }

  factory Achievement.clone(Achievement source) {
    return Achievement(
      id: source.id,
      name: source.name,
      description: source.description,
      icon: source.icon,
      category: source.category,
      totalSteps: source.totalSteps,
      metric: source.metric,
      isUnlocked: source.isUnlocked,
      unlockedDate: source.unlockedDate,
      userProgress: source.userProgress,
    );
  }
}
