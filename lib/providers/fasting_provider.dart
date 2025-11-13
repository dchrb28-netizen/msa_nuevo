import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/fasting_log.dart';
import 'package:myapp/models/fasting_phase.dart';
import 'package:myapp/models/fasting_plan.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class FastingProvider with ChangeNotifier {
  final Box<FastingLog> _fastingBox = Hive.box<FastingLog>('fasting_logs');
  final NotificationService _notificationService = NotificationService();
  Timer? _timer;
  FastingLog? _currentFast;
  FastingPhase? _previousPhase;
  FastingPlan _selectedPlan = FastingPlan.defaultPlans.first;
  Duration _feedingWindowDuration = Duration.zero;

  FastingLog? get currentFast => _currentFast;
  bool get isFasting => _currentFast != null && _currentFast!.endTime == null;
  FastingPlan get selectedPlan => _selectedPlan;
  int get goalInSeconds => _selectedPlan.fastingHours * 3600;
  Duration get feedingWindowDuration => _feedingWindowDuration;

  FastingProvider() {
    _loadPreferences();
    _loadCurrentFast();
    _initializeTimer();
  }

  void _initializeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isFasting) {
        final newPhase = currentPhase;
        if (_previousPhase?.name != newPhase?.name) {
          if (newPhase != null) {
            _notificationService.showNotification(
                1, // Different ID for phase changes
                '¡Nueva Fase Alcanzada!',
                'Has entrado en la fase: ${newPhase.name}');
            _previousPhase = newPhase;
          }
        }

        // Check if goal is reached
        if (_currentFast!.durationInSeconds >= goalInSeconds) {
          // This notification is for when the app is open
          _notificationService.showNotification(
              0, '¡Objetivo Cumplido!', 'Has alcanzado tu meta de ${_selectedPlan.fastingHours} horas. ¡Excelente!');
          stopFasting(); 
        }
      } else {
        _updateFeedingWindow();
      }
      notifyListeners();
    });
  }

  FastingPhase? get currentPhase {
    if (!isFasting) return null;
    final hours = _currentFast!.durationInSeconds / 3600;
    for (var i = FastingPhase.phases.length - 1; i >= 0; i--) {
      if (hours >= FastingPhase.phases[i].startHour) {
        return FastingPhase.phases[i];
      }
    }
    return null;
  }

  List<FastingLog> get fastingHistory {
    return _fastingBox.values.where((log) => log.endTime != null).toList()
      ..sort((a, b) => b.endTime!.compareTo(a.endTime!));
  }

  FastingLog? get longestFastLog {
    if (fastingHistory.isEmpty) return null;
    return fastingHistory.reduce((a, b) {
      final aDuration = a.endTime!.difference(a.startTime);
      final bDuration = b.endTime!.difference(b.startTime);
      return aDuration.inSeconds > bDuration.inSeconds ? a : b;
    });
  }

  Duration get averageFastDuration {
    if (fastingHistory.isEmpty) return Duration.zero;
    final totalDuration = fastingHistory.fold<Duration>(
      Duration.zero,
      (previous, log) => previous + log.endTime!.difference(log.startTime),
    );
    return Duration(seconds: totalDuration.inSeconds ~/ fastingHistory.length);
  }

  void _loadCurrentFast() {
    try {
      _currentFast = _fastingBox.values.firstWhere((log) => log.endTime == null);
      _previousPhase = currentPhase;
    } catch (e) {
      _currentFast = null;
    }
    notifyListeners();
  }

  void _updateFeedingWindow() {
    if (fastingHistory.isNotEmpty) {
      final lastFast = fastingHistory.first;
      _feedingWindowDuration = DateTime.now().difference(lastFast.endTime!);
    } else {
      _feedingWindowDuration = Duration.zero;
    }
  }

  Future<void> setPlan(FastingPlan newPlan) async {
    _selectedPlan = newPlan;
    await _savePreferences();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPlan', _selectedPlan.name);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final planName = prefs.getString('selectedPlan');
    if (planName != null) {
      try {
        _selectedPlan =
            FastingPlan.defaultPlans.firstWhere((p) => p.name == planName);
      } catch (e) {
        _selectedPlan = FastingPlan.defaultPlans.first;
      }
    }
    notifyListeners();
  }

  void startFasting() {
    if (isFasting) return;

    const uuid = Uuid();
    final startTime = DateTime.now();
    final newFast = FastingLog(
      id: uuid.v4(),
      startTime: startTime,
    );
    _fastingBox.put(newFast.id, newFast);
    _currentFast = newFast;
    _previousPhase = null;
    _feedingWindowDuration = Duration.zero;

    // Show immediate notification
    _notificationService.showNotification(
        0, 'Ayuno Iniciado', '¡Tu ayuno ha comenzado! Buen trabajo.');

    // Schedule end-of-fast notification
    final endTime = startTime.add(Duration(hours: _selectedPlan.fastingHours));
    _notificationService.scheduleNotification(
      newFast.id.hashCode,
      '¡Ayuno Completado!',
      '¡Felicidades! Has completado tu ayuno de ${_selectedPlan.fastingHours} horas.',
      endTime,
    );

    notifyListeners();
  }

  void stopFasting() {
    if (!isFasting) return;
    
    final fastToStop = _currentFast!;
    // Cancel the scheduled notification
    _notificationService.cancelNotification(fastToStop.id.hashCode);

    final endTime = DateTime.now();
    final duration = endTime.difference(fastToStop.startTime);

    if (duration.inHours < 1) {
      _fastingBox.delete(fastToStop.id);
      _notificationService.showNotification(
          0, 'Ayuno Cancelado', 'El ayuno fue demasiado corto para ser registrado.');
    } else {
      fastToStop.endTime = endTime;
      fastToStop.save();
      final formatted = _formatDuration(duration);
      _notificationService.showNotification(0, '¡Ayuno Completado!',
          'Has completado un ayuno de $formatted. ¡Felicidades!');
    }

    _currentFast = null;
    _previousPhase = null;
    _updateFeedingWindow();
    notifyListeners();
  }

  Future<void> deleteFastingLog(String logId) async {
    await _fastingBox.delete(logId);
    if (fastingHistory.isNotEmpty && logId == fastingHistory.first.id) {
       _updateFeedingWindow();
    } else if (fastingHistory.isEmpty) {
      _feedingWindowDuration = Duration.zero;
    }
    notifyListeners();
  }

  Future<void> updateFastingLog(FastingLog updatedLog) async {
    await _fastingBox.put(updatedLog.id, updatedLog);
    if (updatedLog.id == fastingHistory.first.id) {
       _updateFeedingWindow();
    }
    notifyListeners();
  }

  String get formattedFastingDuration {
    if (_currentFast == null || isFasting == false) return '00:00:00';
    final duration = Duration(seconds: _currentFast!.durationInSeconds);
    return _formatDuration(duration);
  }

  String get formattedFeedingWindowDuration {
    if (isFasting || _feedingWindowDuration == Duration.zero) return '00:00:00';
    return _formatDuration(_feedingWindowDuration);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return '${hours}h ${minutes}m';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
