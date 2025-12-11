import 'package:flutter/material.dart';

// Nota: Esta clase usa IconData dinámico, lo que requiere:
// flutter build appbundle --release --no-tree-shake-icons
// Esto es necesario porque los iconos se cargan desde Hive

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

  // Metodos de serializacion JSON

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
      'matchTextDirection': icon.matchTextDirection,
    },
    'category': category.name, // Guardar el nombre del enum
    'goal': goal,
    'unit': unit,
    'isUnlocked': isUnlocked,
    'unlockedDate': unlockedDate?.toIso8601String(),
    'progress': progress,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    icon: IconData(
      json['icon']['codePoint'],
      fontFamily: json['icon']['fontFamily'],
      fontPackage: json['icon']['fontPackage'],
      matchTextDirection: json['icon']['matchTextDirection'],
    ),
    category: AchievementCategory.values.firstWhere((e) => e.name == json['category']),
    goal: json['goal'],
    unit: json['unit'],
    isUnlocked: json['isUnlocked'],
    unlockedDate: json['unlockedDate'] != null ? DateTime.parse(json['unlockedDate']) : null,
    progress: json['progress'],
  );
}
