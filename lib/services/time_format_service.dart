import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeFormatService extends ChangeNotifier {
  static final TimeFormatService _instance = TimeFormatService._internal();
  factory TimeFormatService() => _instance;
  TimeFormatService._internal();

  bool _use24HourFormat = true;

  bool get use24HourFormat => _use24HourFormat;

  Future<void> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _use24HourFormat = prefs.getBool('use24HourFormat') ?? true;
    notifyListeners();
  }

  Future<void> setTimeFormat(bool use24Hour) async {
    _use24HourFormat = use24Hour;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use24HourFormat', use24Hour);
    notifyListeners();
  }

  /// Formatea un TimeOfDay según la preferencia del usuario
  String formatTimeOfDay(TimeOfDay time, BuildContext context) {
    if (_use24HourFormat) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
  }

  /// Formatea un DateTime según la preferencia del usuario
  String formatTime(DateTime dateTime) {
    if (_use24HourFormat) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
  }

  /// Formatea hora y minutos según la preferencia del usuario
  String formatHourMinute(int hour, int minute) {
    if (_use24HourFormat) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else {
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      final period = hour >= 12 ? 'PM' : 'AM';
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Formatea fecha y hora completa (dd/MM/yy HH:mm o dd/MM/yy hh:mm AM/PM)
  String formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString().substring(2);
    final timeStr = formatTime(dateTime);
    return '$day/$month/$year $timeStr';
  }
}
