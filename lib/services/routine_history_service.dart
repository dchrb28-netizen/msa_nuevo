import 'dart:convert';
import 'package:myapp/models/routine_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineHistoryService {
  static const _historyKey = 'routine_history';

  Future<void> saveRoutineLog(RoutineLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getRoutineHistory();
    history.add(log);
    final jsonList = history.map((log) => json.encode(log.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<List<RoutineLog>> getRoutineHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    return jsonList
        .map((jsonString) => RoutineLog.fromJson(json.decode(jsonString)))
        .toList();
  }
}
