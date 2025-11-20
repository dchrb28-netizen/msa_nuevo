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
  final int goal; // Renombrado de totalSteps
  final String unit; // Añadido

  // Estado del usuario
  bool isUnlocked;
  DateTime? unlockedDate;
  int progress; // Renombrado de userProgress

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.goal = 1, // Por defecto, un logro se completa en 1 paso
    this.unit = '',
    this.isUnlocked = false,
    this.unlockedDate,
    this.progress = 0,
  });

  double get progressPercentage {
    if (goal <= 0) return 0.0;
    if (isUnlocked) return 1.0;
    return (progress / goal).clamp(0.0, 1.0);
  }

  factory Achievement.clone(Achievement source) {
    return Achievement(
      id: source.id,
      name: source.name,
      description: source.description,
      icon: source.icon,
      category: source.category,
      goal: source.goal,
      unit: source.unit,
      isUnlocked: source.isUnlocked,
      unlockedDate: source.unlockedDate,
      progress: source.progress,
    );
  }
}
