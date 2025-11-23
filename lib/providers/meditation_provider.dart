import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/meditation_log.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:uuid/uuid.dart';

class MeditationProvider with ChangeNotifier {
  final Box<MeditationLog> _meditationLogBox = Hive.box<MeditationLog>('meditation_logs');
  final AchievementService _achievementService = AchievementService();

  List<MeditationLog> get meditationLogs => _meditationLogBox.values.toList();

  Future<void> addMeditationLog(DateTime startTime, DateTime endTime) async {
    final duration = endTime.difference(startTime).inSeconds;
    if (duration <= 0) return;

    final newLog = MeditationLog(
      id: const Uuid().v4(),
      startTime: startTime,
      endTime: endTime,
      durationInSeconds: duration,
    );

    await _meditationLogBox.add(newLog);

    // Otorgar 10 XP por cada sesión de meditación
    _achievementService.grantExperience(10);

    // Actualizar el logro de la primera meditación
    _achievementService.updateProgress('first_meditation', 1);

    notifyListeners();
  }
}
