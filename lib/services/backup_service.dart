import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
  ];

  /// Serializa un valor a un formato compatible con JSON.
  dynamic _toJson(dynamic value) {
    if (value is User) return value.toJson();
    if (value is UserProfile) return value.toJson();
    if (value is Food) return value.toJson();
    if (value is WaterLog) return value.toJson();
    if (value is FoodLog) return value.toJson();
    if (value is BodyMeasurement) return value.toJson();
    if (value is DailyMealPlan) return value.toJson();
    if (value is Recipe) return value.toJson();

    if (value is Map ||
        value is List ||
        value is String ||
        value is num ||
        value is bool ||
        value == null) {
      return value;
    }

    if (kDebugMode) {
      print(
          'Backup warning: Unsupported type ${value.runtimeType} encountered. Value will be stored as a string.');
    }
    return value.toString();
  }

  /// Deserializa un mapa JSON al objeto Dart correspondiente.
  dynamic _fromJson(String boxName, dynamic jsonValue) {
    if (jsonValue == null) return null;

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
  }

  /// Exportar todos los datos a un archivo JSON
  Future<String?> exportBackup() async {
    try {
      final Map<String, dynamic> backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.1', // VersiÃ³n con serializaciÃ³n corregida
        'data': {},
        'preferences': {},
      };

      // Exportar cada caja
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
            print('Error al exportar caja $boxName: $e');
          }
        }
      }

      // Exportar SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final prefsMap = <String, dynamic>{};
        for (final key in prefs.getKeys()) {
          prefsMap[key] = prefs.get(key);
        }
        backup['preferences'] = prefsMap;
      } catch (e) {
        if (kDebugMode) {
          print('Error al exportar preferencias: $e');
        }
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);

      if (kIsWeb) {
        return jsonString;
      } else {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'fitflow_backup_$timestamp.json';

        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar respaldo',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsString(jsonString);
          return file.path;
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear respaldo: $e');
      }
      return null;
    }
  }

  /// Importar datos desde un archivo JSON
  Future<bool> importBackup() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error al seleccionar archivo: $e");
      }
      return false;
    }

    if (result == null || result.files.isEmpty) return false;

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

      if (jsonString == null) return false;

      final Map<String, dynamic> backup = json.decode(jsonString);
      final Map<String, dynamic> data = backup['data'] as Map<String, dynamic>;

      // Primero, cierra todas las cajas para evitar conflictos
      await Hive.close();

      // Limpia y restaura cada caja
      for (final entry in data.entries) {
        final boxName = entry.key;
        final boxData = entry.value as Map<String, dynamic>;

        try {
          final box = await Hive.openBox(boxName);
          await box.clear(); // Limpiar la caja antes de restaurar

          for (final dataEntry in boxData.entries) {
            final key = dataEntry.key;
            final value = dataEntry.value;
            final objectToStore = _fromJson(boxName, value);
            if (objectToStore != null) {
              await box.put(key, objectToStore);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error al restaurar caja $boxName: $e');
          }
        }
      }

      // Restaurar SharedPreferences
      if (backup.containsKey('preferences')) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear(); // Limpiar preferencias existentes
          final prefsData = backup['preferences'] as Map<String, dynamic>;

          for (final entry in prefsData.entries) {
            final key = entry.key;
            final value = entry.value;
            if (value is bool) await prefs.setBool(key, value);
            if (value is int) await prefs.setInt(key, value);
            if (value is double) await prefs.setDouble(key, value);
            if (value is String) await prefs.setString(key, value);
            if (value is List<dynamic>) {
              await prefs.setStringList(key, value.cast<String>());
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error al restaurar preferencias: $e');
          }
        }
      }

      if (kDebugMode) {
        print('âœ… Respaldo restaurado exitosamente');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al importar respaldo: $e');
      }
      return false;
    }
  }

  Future<int> getEstimatedBackupSize() async {
    int totalSize = 0;
    for (final boxName in _boxNames) {
      try {
        final box = await Hive.openBox(boxName);
        totalSize += box.length;
      } catch (e) {
        // Ignorar errores
      }
    }
    return totalSize;
  }
}
