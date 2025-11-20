import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:myapp/models/workout_session.dart';
import 'package:myapp/services/streaks_service.dart'; // Importar el servicio de rachas

class WorkoutHistoryProvider with ChangeNotifier {
  final StreaksService _streaksService = StreaksService(); // Instanciar el servicio
  final List<WorkoutSession> _workoutHistory = [];

  List<WorkoutSession> get workoutHistory => _workoutHistory;

  void addWorkoutSession(WorkoutSession session) {
    _workoutHistory.insert(0, session);
    notifyListeners();
    developer.log(
      'Workout session for ${session.routineName} on ${session.date} saved. History count: ${_workoutHistory.length}',
      name: 'WorkoutHistoryProvider',
    );

    // --- Lógica de Rachas ---
    _streaksService.updateWorkoutStreak();
    // --- Fin Lógica de Rachas ---
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

  // Necesario para la función "Deshacer"
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
      return null; // Retorna null si no se encuentra
    }
  }
}
