import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/fasting_log.dart';
import 'package:myapp/models/fasting_phase.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class FastingProvider with ChangeNotifier {
  final Box<FastingLog> _fastingBox = Hive.box<FastingLog>('fasting_logs');
  final NotificationService _notificationService = NotificationService();
  Timer? _timer;
  FastingLog? _currentFast;
  FastingPhase? _previousPhase;

  FastingLog? get currentFast => _currentFast;
  bool get isFasting => _currentFast != null && _currentFast!.endTime == null;

  FastingProvider() {
    _loadCurrentFast();
  }

  FastingPhase? get currentPhase {
    if (!isFasting) return null;
    final hours = _currentFast!.durationInSeconds / 3600;
    return FastingPhase.phases.lastWhere((phase) => hours >= phase.startHour);
  }

  List<FastingLog> get fastingHistory {
    return _fastingBox.values.where((log) => log.endTime != null).toList()
      ..sort((a, b) => b.endTime!.compareTo(a.endTime!));
  }

  void _loadCurrentFast() {
    try {
      _currentFast =
          _fastingBox.values.firstWhere((log) => log.endTime == null);
      if (_currentFast != null) {
        _startTimer();
      }
    } catch (e) {
      _currentFast = null;
    }
    notifyListeners();
  }

  void startFasting() {
    if (isFasting) return;

    const uuid = Uuid();
    final newFast = FastingLog(
      id: uuid.v4(),
      startTime: DateTime.now(),
    );
    _fastingBox.put(newFast.id, newFast);
    _currentFast = newFast;
    _notificationService.showNotification(
        0, 'Ayuno Iniciado', '¡Tu ayuno ha comenzado! Buen trabajo.');
    _startTimer();
    notifyListeners();
  }

  void stopFasting() {
    if (!isFasting) return;

    _currentFast!.endTime = DateTime.now();
    _currentFast!.save();
    _timer?.cancel();
    _currentFast = null;
    _previousPhase = null; 
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isFasting) {
        timer.cancel();
      } else {
        final newPhase = currentPhase;
        if (_previousPhase?.name != newPhase?.name) {
          _notificationService.showNotification(0, '¡Nueva Fase Alcanzada!',
              'Has entrado en la fase: ${newPhase?.name}');
          _previousPhase = newPhase;
        }
        notifyListeners(); // Notify listeners every second to update UI
      }
    });
  }

  String get formattedDuration {
    if (!isFasting) return '00:00:00';
    final duration = Duration(seconds: _currentFast!.durationInSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
