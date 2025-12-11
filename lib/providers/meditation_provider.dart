
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/meditation_log.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/streaks_service.dart';
import 'package:uuid/uuid.dart';

class MeditationProvider with ChangeNotifier {
  final Box<String> _meditationLogBox = Hive.box<String>('meditation_logs_json');
  final AchievementService _achievementService = AchievementService();
  final StreaksService _streaksService = StreaksService();

  List<MeditationLog> get meditationLogs {
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

    await _meditationLogBox.add(newLog.toJson());

    _achievementService.grantExperience(10);
    _achievementService.updateProgress('first_meditation', 1);

    // Actualizar racha de meditaciÃ³n
    await _streaksService.updateMeditationStreak(newLog);

    notifyListeners();
  }

  Future<void> deleteMeditationLog(String logId) async {
    final logs = meditationLogs;
    final index = logs.indexWhere((log) => log.id == logId);
    
    if (index != -1) {
      final keys = _meditationLogBox.keys.toList();
      await _meditationLogBox.delete(keys[index]);
      notifyListeners();
    }
  }
}
