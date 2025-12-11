
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/meditation_log.dart';


// Modelo de datos oficial para una racha
class StreakData {
  final String key; // Identificador único, ej: 'hydration'
  final int currentStreak;
  final int recordStreak;
  final DateTime lastUpdate;

  StreakData({
    required this.key,
    required this.currentStreak,
    required this.recordStreak,
    required this.lastUpdate,
  });
}

class StreaksService {
  static const String _hydrationKey = 'hydration';
  static const String _mealKey = 'meal';
  static const String _workoutKey = 'workout';
  static const String _calorieKey = 'calorie';
  static const String _fastingKey = 'fasting';
  static const String _meditationKey = 'meditation';

  // --- MÉTODOS PÚBLICOS PARA ACTUALIZAR RACHAS ---

  Future<void> updateHydrationStreak() => _updateStreak(_hydrationKey);
  Future<void> updateMealStreak() => _updateStreak(_mealKey);
  Future<void> updateWorkoutStreak() => _updateStreak(_workoutKey);
  Future<void> updateCalorieStreak() => _updateStreak(_calorieKey);
  Future<void> updateFastingStreak() => _updateStreak(_fastingKey);

  Future<void> updateMeditationStreak(MeditationLog log) async {
    final prefs = await SharedPreferences.getInstance();
    const key = _meditationKey;
    final eventDate = log.endTime; // Use the log's date
    final eventDay = DateUtils.dateOnly(eventDate);

    final data = await _getStreakData(key);
    final lastUpdateDate = DateUtils.dateOnly(data.lastUpdate);

    if (lastUpdateDate.isAtSameMomentAs(eventDay)) {
      return; // Ya se actualizó para este día
    }

    int newCurrentStreak;
    final yesterday = eventDay.subtract(const Duration(days: 1));

    if (lastUpdateDate.isAtSameMomentAs(yesterday)) {
      // La racha continúa
      newCurrentStreak = data.currentStreak + 1;
    } else {
      // La racha se rompió o es nueva
      newCurrentStreak = 1;
    }

    final newRecordStreak = newCurrentStreak > data.recordStreak ? newCurrentStreak : data.recordStreak;

    // Guardar los nuevos valores
    await prefs.setInt('streak_${key}_current', newCurrentStreak);
    await prefs.setInt('streak_${key}_record', newRecordStreak);
    await prefs.setInt('streak_${key}_lastUpdate', eventDate.millisecondsSinceEpoch);
  }


  // --- MÉTODOS PÚBLICOS PARA OBTENER RACHAS ---

  Future<StreakData> getHydrationStreak() => _getStreakData(_hydrationKey);
  Future<StreakData> getMealStreak() => _getStreakData(_mealKey);
  Future<StreakData> getWorkoutStreak() => _getStreakData(_workoutKey);
  Future<StreakData> getCalorieStreak() => _getStreakData(_calorieKey);
  Future<StreakData> getFastingStreak() => _getStreakData(_fastingKey);
  Future<StreakData> getMeditationStreak() => _getStreakData(_meditationKey);

  // --- LÓGICA INTERNA ---

  Future<void> _updateStreak(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    final data = await _getStreakData(key);
    final lastUpdateDate = DateUtils.dateOnly(data.lastUpdate);

    if (lastUpdateDate.isAtSameMomentAs(today)) {
      return; // Ya se actualizó hoy
    }

    int newCurrentStreak;
    final yesterday = today.subtract(const Duration(days: 1));

    if (lastUpdateDate.isAtSameMomentAs(yesterday)) {
      // La racha continúa
      newCurrentStreak = data.currentStreak + 1;
    } else {
      // La racha se rompió o es nueva
      newCurrentStreak = 1;
    }

    final newRecordStreak = newCurrentStreak > data.recordStreak ? newCurrentStreak : data.recordStreak;

    // Guardar los nuevos valores
    await prefs.setInt('streak_${key}_current', newCurrentStreak);
    await prefs.setInt('streak_${key}_record', newRecordStreak);
    await prefs.setInt('streak_${key}_lastUpdate', now.millisecondsSinceEpoch);
  }

  Future<StreakData> _getStreakData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('streak_${key}_current') ?? 0;
    final record = prefs.getInt('streak_${key}_record') ?? 0;
    final lastUpdateMillis = prefs.getInt('streak_${key}_lastUpdate');
    
    final lastUpdate = lastUpdateMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis)
        : DateTime.fromMicrosecondsSinceEpoch(0);

    // Lógica para reiniciar la racha si el último registro no fue ayer
    final today = DateUtils.dateOnly(DateTime.now());
    final lastUpdateDate = DateUtils.dateOnly(lastUpdate);
    final yesterday = today.subtract(const Duration(days: 1));

    if (current > 0 && !lastUpdateDate.isAtSameMomentAs(today) && !lastUpdateDate.isAtSameMomentAs(yesterday)) {
        await prefs.setInt('streak_${key}_current', 0);
        return StreakData(
            key: key,
            currentStreak: 0,
            recordStreak: record,
            lastUpdate: lastUpdate,
        );
    }

    return StreakData(
      key: key,
      currentStreak: current,
      recordStreak: record,
      lastUpdate: lastUpdate,
    );
  }
}
