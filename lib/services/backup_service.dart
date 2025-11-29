import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/achievement.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/daily_meal_plan.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/fasting_log.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/models/meal_entry.dart';
import 'package:myapp/models/meditation_log.dart';
import 'package:myapp/models/recipe.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/models/water_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';

enum ExportStatus { success, failure, webDownloadInitiated, cancelled }

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final _boxNames = const [
    'user_box',
    'profile_data',
    'foods',
    'water_logs',
    'food_logs',
    'body_measurements',
    'daily_meal_plans',
    'settings',
    'favorite_recipes',
    'user_recipes',
    'reminders',
    'fasting_logs',
    'routines',
    'routine_logs',
    'exercises',
    'routine_exercises',
    'meal_entries',
    'meditation_logs_json',
    'achievements',
  ];

  dynamic _toJson(dynamic value) {
    if (value is User) return value.toJson();
    if (value is UserProfile) return value.toJson();
    if (value is Food) return value.toJson();
    if (value is WaterLog) return value.toJson();
    if (value is FoodLog) return value.toJson();
    if (value is BodyMeasurement) return value.toJson();
    if (value is DailyMealPlan) return value.toJson();
    if (value is Recipe) return value.toJson();
    if (value is Reminder) return value.toJson();
    if (value is FastingLog) return value.toJson();
    if (value is Routine) return value.toJson();
    if (value is RoutineLog) return value.toJson();
    if (value is Exercise) return value.toJson();
    if (value is RoutineExercise) return value.toJson();
    if (value is MealEntry) return value.toJson();
    if (value is MeditationLog) return value.toJson();
    if (value is Achievement) return value.toJson();
    if (value is Map || value is List || value is String || value is num || value is bool || value == null) {
      return value;
    }
    return value.toString();
  }

  dynamic _fromJson(String boxName, dynamic jsonValue) {
    if (jsonValue == null) return null;
    try {
      switch (boxName) {
        case 'user_box':
          return User.fromJson(jsonValue);
        case 'profile_data':
          return UserProfile.fromJson(jsonValue);
        case 'foods':
          return Food.fromJson(jsonValue);
        case 'water_logs':
          return WaterLog.fromJson(jsonValue);
        case 'food_logs':
          return FoodLog.fromJson(jsonValue);
        case 'body_measurements':
          return BodyMeasurement.fromJson(jsonValue);
        case 'daily_meal_plans':
          return DailyMealPlan.fromJson(jsonValue);
        case 'favorite_recipes':
        case 'user_recipes':
          return Recipe.fromJson(jsonValue);
        case 'reminders':
          return Reminder.fromJson(jsonValue);
        case 'fasting_logs':
          return FastingLog.fromJson(jsonValue);
        case 'routines':
          return Routine.fromJson(jsonValue);
        case 'routine_logs':
          return RoutineLog.fromJson(jsonValue);
        case 'exercises':
          return Exercise.fromJson(jsonValue);
        case 'routine_exercises':
          return RoutineExercise.fromJson(jsonValue);
        case 'meal_entries':
          return MealEntry.fromJson(jsonValue);
        case 'meditation_logs_json':
          return MeditationLog.fromJson(jsonValue);
        case 'achievements':
          return Achievement.fromJson(jsonValue);
        default:
          return jsonValue;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in _fromJson for box $boxName: $e - Value: $jsonValue');
      }
      return null;
    }
  }

  Future<ExportStatus> exportBackup() async {
    try {
      final Map<String, dynamic> backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.5.6', // Corregido el problema de temporización en la web
        'data': {},
        'preferences': {},
      };

      for (final boxName in _boxNames) {
        try {
          final box = await Hive.openBox(boxName);
          final Map<String, dynamic> boxData = {};
          for (final key in box.keys) {
            boxData[key.toString()] = _toJson(box.get(key));
          }
          backup['data'][boxName] = boxData;
        } catch (e) {
          if (kDebugMode) {
            print('Error exportando caja $boxName: $e');
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final prefsMap = <String, dynamic>{};
      for (final key in prefs.getKeys()) {
        prefsMap[key] = prefs.get(key);
      }
      backup['preferences'] = prefsMap;

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      final bytes = utf8.encode(jsonString);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'fitflow_backup_$timestamp';

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", '$fileName.json')
          ..click();

        Future.delayed(const Duration(milliseconds: 100), () {
          html.Url.revokeObjectUrl(url);
        });

        return ExportStatus.webDownloadInitiated;
      } else {
        String? path = await FileSaver.instance.saveAs(
          name: fileName,
          bytes: bytes,
          fileExtension: 'json',
          mimeType: MimeType.json,
        );
        if (path != null && path.isNotEmpty) {
          return ExportStatus.success;
        } else {
          return ExportStatus.cancelled;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creando respaldo: $e');
      }
      return ExportStatus.failure;
    }
  }

 Future<List<User>?> importBackup() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    } catch (e) {
      if (kDebugMode) {
        print("Error al seleccionar archivo: $e");
      }
      return null; // Error
    }

    if (result == null || result.files.isEmpty) {
      return null; // Cancelled
    }

    try {
      String? jsonString;
      if (kIsWeb) {
        final bytes = result.files.first.bytes;
        if (bytes != null) {
          jsonString = utf8.decode(bytes);
        }
      } else {
        final path = result.files.first.path;
        if (path != null) {
          jsonString = await File(path).readAsString();
        }
      }

      if (jsonString == null || jsonString.isEmpty) {
        return null; // Invalid file
      }

      final backup = json.decode(jsonString);
      if (backup is! Map<String, dynamic> || !backup.containsKey('data')) {
        return null; // Invalid file format
      }

      // 1. Clear all data first
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      for (final boxName in _boxNames) {
        try {
          final box = await Hive.openBox(boxName);
          await box.clear();
        } catch (e) {
          if (kDebugMode) {
            print('Advertencia al limpiar la caja $boxName: $e');
          }
        }
      }
      
      // 2. Restore SharedPreferences
      final prefsData = backup['preferences'] as Map<String, dynamic>? ?? {};
      for (final entry in prefsData.entries) {
        final key = entry.key;
        final value = entry.value;
        try {
          if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is String) {
            await prefs.setString(key, value);
          } else if (value is List) {
            await prefs.setStringList(key, value.cast<String>());
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error restaurando preferencia "$key": $e');
          }
        }
      }

      // 3. Restore Hive boxes
      final Map<String, dynamic> data = backup['data'];
      for (final boxName in data.keys) {
        if (!_boxNames.contains(boxName)) continue;
        try {
          final boxData = data[boxName];
          if (boxData is! Map<String, dynamic>) continue;
          final box = await Hive.openBox(boxName);
          for (final entry in boxData.entries) {
            try {
              final objectToStore = _fromJson(boxName, entry.value);
              if (objectToStore != null) {
                await box.put(entry.key, objectToStore);
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error restaurando registro "${entry.key}" en "$boxName": $e');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error crítico restaurando la caja "$boxName": $e. Se saltará esta caja.');
          }
        }
      }

      // 4. Extract and return the imported users
      final List<User> importedUsers = [];
      final userBoxData = data['user_box'] as Map<String, dynamic>?;
      if (userBoxData != null) {
        for (final userJson in userBoxData.values) {
          try {
            final user = _fromJson('user_box', userJson);
            // Asegurarse de que el objeto no sea nulo y sea del tipo correcto (no sea guest)
            if (user is User && !user.isGuest) {
              importedUsers.add(user);
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error convirtiendo usuario desde JSON durante la importación: $e');
            }
          }
        }
      }

      return importedUsers;

    } catch (e) {
      if (kDebugMode) {
        print('Error al decodificar o procesar el archivo JSON: $e');
      }
      return null; // Critical error during processing
    }
  }
}
