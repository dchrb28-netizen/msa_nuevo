
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/meditation_log.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:uuid/uuid.dart';

class MeditationProvider with ChangeNotifier {
  // Cambiamos la caja para que almacene Strings (JSON) en lugar de objetos complejos.
  final Box<String> _meditationLogBox = Hive.box<String>('meditation_logs_json');
  final AchievementService _achievementService = AchievementService();

  List<MeditationLog> get meditationLogs {
    // Leemos los strings JSON y los convertimos de nuevo a objetos MeditationLog.
    return _meditationLogBox.values.map((jsonString) {
      return MeditationLog.fromJson(jsonString);
    }).toList();
  }

  Future<void> addMeditationLog(DateTime startTime, DateTime endTime) async {
    final duration = endTime.difference(startTime).inSeconds;
    if (duration <= 0) return;

    final newLog = MeditationLog(
      id: const Uuid().v4(),
      startTime: startTime,
      endTime: endTime,
      durationInSeconds: duration,
    );

    // Convertimos el objeto a un String JSON antes de guardarlo.
    await _meditationLogBox.add(newLog.toJson());

    _achievementService.grantExperience(10);
    _achievementService.updateProgress('first_meditation', 1);

    notifyListeners();
  }

  Future<void> deleteMeditationLog(String logId) async {
    // Buscar el índice del log por su ID
    final logs = meditationLogs;
    final index = logs.indexWhere((log) => log.id == logId);
    
    if (index != -1) {
      // Eliminar usando la clave del box (el índice)
      final keys = _meditationLogBox.keys.toList();
      await _meditationLogBox.delete(keys[index]);
      notifyListeners();
    }
  }
}
