// lib/providers/workout_history_provider.dart

import 'package:flutter/foundation.dart';
import 'package:myapp/models/workout_session.dart';

class WorkoutHistoryProvider with ChangeNotifier {
  final List<WorkoutSession> _workoutHistory = [];

  List<WorkoutSession> get workoutHistory => _workoutHistory;

  void addWorkoutSession(WorkoutSession session) {
    _workoutHistory.add(session);
    notifyListeners();
    print('Workout session for ${session.routineName} on ${session.date} saved. History count: ${_workoutHistory.length}');
  }

  // Aquí podrías añadir más métodos en el futuro, como:
  // void deleteWorkoutSession(String sessionId) { ... }
  // WorkoutSession? getSessionById(String sessionId) { ... }
}
