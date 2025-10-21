import 'package:flutter/foundation.dart';

@immutable
class FastingPlan {
  final String name;
  final int fastingHours;

  const FastingPlan({required this.name, required this.fastingHours});

  int get feedingHours => 24 - fastingHours;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastingPlan &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          fastingHours == other.fastingHours;

  @override
  int get hashCode => name.hashCode ^ fastingHours.hashCode;


  static List<FastingPlan> get defaultPlans => const [
    FastingPlan(name: '16:8', fastingHours: 16),
    FastingPlan(name: '18:6', fastingHours: 18),
    FastingPlan(name: '20:4', fastingHours: 20),
    FastingPlan(name: '12:12', fastingHours: 12),
  ];
}
