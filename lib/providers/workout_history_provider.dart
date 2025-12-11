import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:myapp/models/workout_session.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/streaks_service.dart';

class WorkoutHistoryProvider with ChangeNotifier {
  final StreaksService _streaksService = StreaksService();
  final AchievementService _achievementService = AchievementService();
  final List<WorkoutSession> _workoutHistory = [];

  List<WorkoutSession> get workoutHistory => _workoutHistory;

  // Helper para calcular el peso total levantado en toda la historia
  int _calculateTotalWeightLifted() {
    double totalWeight = 0;
    for (var session in _workoutHistory) {
      for (var exercise in session.performedExercises) {
        for (var set in exercise.sets) {
          totalWeight += set.reps * set.weight;
        }
      }
    }
    return totalWeight.toInt();
  }

  void addWorkoutSession(WorkoutSession session) {
    _workoutHistory.insert(0, session);
    
    developer.log(
      'Workout session for ${session.routineName} on ${session.date} saved. History count: ${_workoutHistory.length}',
      name: 'WorkoutHistoryProvider',
    );

    // --- Lógica de Rachas ---
    _streaksService.updateWorkoutStreak();
    
    // --- Lógica de Logros ---
    _achievementService.grantExperience(25);
    _achievementService.updateProgress('first_workout', 1);

    final totalWorkouts = _workoutHistory.length;
    _achievementService.updateProgress('cum_train_25', totalWorkouts, cumulative: true);
    _achievementService.updateProgress('cum_train_100', totalWorkouts, cumulative: true);
    
    // Calcular y actualizar logros de levantamiento de peso
    final totalWeight = _calculateTotalWeightLifted();
    _achievementService.updateProgress('cum_lift_50k', totalWeight, cumulative: true);
    // --- Fin Lógica de Logros ---

    notifyListeners();
  }

  void deleteWorkoutSession(String sessionId) {
    final index = _workoutHistory.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _workoutHistory.removeAt(index);
      notifyListeners();
      developer.log(
        'Workout session with id $sessionId deleted.',
        name: 'WorkoutHistoryProvider',
      );
    }
  }

  void addWorkoutSessionAtIndex(int index, WorkoutSession session) {
    _workoutHistory.insert(index, session);
    notifyListeners();
    developer.log(
      'Workout session with id ${session.id} re-inserted at index $index.',
      name: 'WorkoutHistoryProvider',
    );
  }

  WorkoutSession? getSessionById(String sessionId) {
    try {
      return _workoutHistory.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }
}
