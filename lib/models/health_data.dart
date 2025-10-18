import 'package:flutter/material.dart';

// Definición de colores pastel
const Color waterBlue = Color(0xFF42A5F5); // Azul para agua
const Color calorieOrange = Color(0xFFFF7043); // Naranja para calorías
const Color workoutGreen = Color(0xFF66BB6A); // Verde para entrenamiento

/// Modelo de datos para almacenar el estado de salud y fitness del usuario.
class HealthData {
  final int waterIntake;
  final int waterGoal;
  final int calorieIntake;
  final int calorieGoal;
  final String lastWorkout;

  HealthData({
    this.waterIntake = 0,
    this.waterGoal = 2500,
    this.calorieIntake = 0,
    this.calorieGoal = 1500,
    this.lastWorkout = 'No registrado',
  });

  /// Crea una copia de HealthData, permitiendo actualizar solo los campos necesarios.
  HealthData copyWith({
    int? waterIntake,
    int? calorieIntake,
    String? lastWorkout,
  }) {
    return HealthData(
      waterIntake: waterIntake ?? this.waterIntake,
      waterGoal: waterGoal,
      calorieIntake: calorieIntake ?? this.calorieIntake,
      calorieGoal: calorieGoal,
      lastWorkout: lastWorkout ?? this.lastWorkout,
    );
  }
}
