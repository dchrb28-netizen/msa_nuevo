import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:uuid/uuid.dart';

class RoutineProvider with ChangeNotifier {
  final Box<Routine> _routineBox = Hive.box<Routine>('routines');
  final Box<RoutineLog> _routineLogBox = Hive.box<RoutineLog>('routine_logs');
  final Uuid _uuid = const Uuid();

  List<Routine> get routines => _routineBox.values.toList();
  List<RoutineLog> get routineLogs => _routineLogBox.values.toList();

  // ****** Routine Methods ******

  Future<void> addRoutine(Routine routine) async {
    routine.id = _uuid.v4(); // Assign a unique ID
    await _routineBox.put(routine.id, routine);
    notifyListeners();
  }

  Future<void> updateRoutine(String id, Routine routine) async {
    await _routineBox.put(id, routine);
    notifyListeners();
  }

  Future<void> deleteRoutine(String id) async {
    await _routineBox.delete(id);
    notifyListeners();
  }

  // ****** RoutineLog Methods ******

  Future<void> addRoutineLog(RoutineLog routineLog) async {
    await _routineLogBox.add(routineLog); // Using add for auto-incrementing key
    notifyListeners();
  }

  // You can add more methods here to get specific logs, etc.
  List<RoutineLog> getRoutineLogsByDate(DateTime date) {
    return _routineLogBox.values
        .where((log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day)
        .toList();
  }
}
