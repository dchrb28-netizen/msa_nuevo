import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/daily_meal_plan.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/models/recipe.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/models/water_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';

enum ImportStatus { success, cancelled, invalidFile }
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
    if (value is User) {
      return value.toJson();
    }
    if (value is UserProfile) {
      return value.toJson();
    }
    if (value is Food) {
      return value.toJson();
    }
    if (value is WaterLog) {
      return value.toJson();
    }
    if (value is FoodLog) {
      return value.toJson();
    }
    if (value is BodyMeasurement) {
      return value.toJson();
    }
    if (value is DailyMealPlan) {
      return value.toJson();
    }
    if (value is Recipe) {
      return value.toJson();
    }
    if (value is Map ||
        value is List ||
        value is String ||
        value is num ||
        value is bool ||
        value == null) {
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
        default:
          return jsonValue;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en _fromJson para la caja $boxName: $e - Valor: $jsonValue');
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

        // Damos tiempo al navegador para procesar la descarga antes de revocar la URL.
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

  Future<ImportStatus> importBackup() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    } catch (e) {
      if (kDebugMode) {
        print("Error al seleccionar archivo: $e");
      }
      return ImportStatus.invalidFile;
    }

    if (result == null || result.files.isEmpty) {
      return ImportStatus.cancelled;
    }

    String? jsonString;
    try {
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
        return ImportStatus.invalidFile;
      }

      final backup = json.decode(jsonString);
      if (backup is! Map<String, dynamic> || !backup.containsKey('data')) {
        return ImportStatus.invalidFile;
      }

      final Map<String, dynamic> data = backup['data'];

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

      for (final boxName in data.keys) {
        if (!_boxNames.contains(boxName)) {
          continue;
        }
        try {
          final boxData = data[boxName];
          if (boxData is! Map<String, dynamic>) {
            continue;
          }
          final box = await Hive.openBox(boxName);
          for (final entry in boxData.entries) {
            try {
              final objectToStore = _fromJson(boxName, entry.value);
              if (objectToStore != null) {
                await box.put(entry.key, objectToStore);
              }
            } catch (e) {
              if (kDebugMode) {
                print(
                    'Error restaurando registro "${entry.key}" en "$boxName": $e');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                'Error crítico restaurando la caja "$boxName": $e. Se saltará esta caja.');
          }
        }
      }

      return ImportStatus.success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al decodificar o procesar el archivo JSON: $e');
      }
      return ImportStatus.invalidFile;
    }
  }
}
