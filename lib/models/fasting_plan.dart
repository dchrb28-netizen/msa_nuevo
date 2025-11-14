import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

@immutable
class FastingPlan {
  final String id;
  final String name;
  final int fastingHours;
  final bool isCustom;

  FastingPlan({
    String? id,
    required this.name,
    required this.fastingHours,
    this.isCustom = false,
  }) : id = id ?? const Uuid().v4();

  int get feedingHours => 24 - fastingHours;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastingPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          fastingHours == other.fastingHours &&
          isCustom == other.isCustom;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      fastingHours.hashCode ^
      isCustom.hashCode;

  FastingPlan copyWith({
    String? id,
    String? name,
    int? fastingHours,
    bool? isCustom,
  }) {
    return FastingPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      fastingHours: fastingHours ?? this.fastingHours,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fastingHours': fastingHours,
      'isCustom': isCustom,
    };
  }

  factory FastingPlan.fromJson(Map<String, dynamic> map) {
    return FastingPlan(
      id: map['id'],
      name: map['name'],
      fastingHours: map['fastingHours'] as int,
      isCustom: map['isCustom'] as bool,
    );
  }

  static List<FastingPlan> get defaultPlans => [
        FastingPlan(name: '16:8', fastingHours: 16),
        FastingPlan(name: '18:6', fastingHours: 18),
        FastingPlan(name: '20:4', fastingHours: 20),
        FastingPlan(name: '12:12', fastingHours: 12),
      ];
}
