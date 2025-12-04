import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

enum ExportStatus { success, failure, webDownloadInitiated, cancelled, permissionDenied }

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

  final Map<String, Function> _serializers = {
    'user_box': (user) => (user as User).toJson(),
    'profile_data': (profile) {
      if (profile is UserProfile) return profile.toJson();
      if (profile is Map) return profile;
      return null;
    },
    'foods': (food) => (food as Food).toJson(),
    'water_logs': (log) => (log as WaterLog).toJson(),
    'food_logs': (log) => (log as FoodLog).toJson(),
    'body_measurements': (measurement) => (measurement as BodyMeasurement).toJson(),
    'daily_meal_plans': (plan) => (plan as DailyMealPlan).toJson(),
    'favorite_recipes': (recipe) => (recipe as Recipe).toJson(),
    'user_recipes': (recipe) => (recipe as Recipe).toJson(),
    'reminders': (reminder) => (reminder as Reminder).toJson(),
    'fasting_logs': (log) => (log as FastingLog).toJson(),
    'routines': (routine) => (routine as Routine).toJson(),
    'routine_logs': (log) => (log as RoutineLog).toJson(),
    'exercises': (exercise) => (exercise as Exercise).toJson(),
    'routine_exercises': (re) => (re as RoutineExercise).toJson(),
    'meal_entries': (entry) => (entry as MealEntry).toJson(),
    'meditation_logs_json': (log) => (log as MeditationLog).toJson(),
    'achievements': (achievement) => (achievement as Achievement).toJson(),
  };

  dynamic _fromJson(String boxName, dynamic jsonValue) {
    if (jsonValue == null) return null;
    try {
      switch (boxName) {
        case 'user_box':
          return User.fromJson(jsonValue);
        case 'profile_data':
          // ** LA CORRECCIÓN DEFINITIVA **
          // Hacemos un "viaje de ida y vuelta" para limpiar los datos antes de guardarlos.
          // 1. Reconstruimos el objeto desde el JSON del respaldo.
          final profileObject = UserProfile.fromJson(Map<String, dynamic>.from(jsonValue));
          // 2. Lo convertimos de nuevo a un mapa JSON "limpio".
          // Esto garantiza que los tipos de datos (ej. DateTime) sean compatibles con Hive.
          return profileObject.toJson();
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
      if (kDebugMode) print('🔵 Iniciando exportación de respaldo...');
      
      final Map<String, dynamic> backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.5.6',
        'data': {},
        'preferences': {},
      };

      for (final boxName in _boxNames) {
        try {
          // Abrir la caja con el tipo correcto para user_box
          final box = boxName == 'user_box' 
              ? await Hive.openBox<User>(boxName)
              : await Hive.openBox(boxName);
          final Map<String, dynamic> boxData = {};
          
          final serializer = _serializers[boxName];

          for (final key in box.keys) {
            final value = box.get(key);
            if (value == null) continue;
            if (serializer != null) {
              boxData[key.toString()] = serializer(value);
            } else {
              boxData[key.toString()] = value;
            }
          }
          
          if (boxName == 'user_box' && kDebugMode) {
            print('📦 Exportando user_box: ${boxData.length} usuarios');
            print('👥 IDs de usuarios: ${boxData.keys.join(", ")}');
          }
          
          backup['data'][boxName] = boxData;
        } catch (e) {
          if (kDebugMode) {
            print('Error exporting box $boxName: $e');
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
        Future.delayed(const Duration(milliseconds: 100), () => html.Url.revokeObjectUrl(url));
        return ExportStatus.webDownloadInitiated;
      } else {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName.json';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        final xfile = XFile(filePath, mimeType: 'application/json');

        await Share.shareXFiles(
          [xfile],
          subject: 'FitFlow Backup',
          text: 'Here is your FitFlow data backup from ${DateTime.now().toLocal()}.',
        );

        return ExportStatus.success;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating backup: $e');
      }
      return ExportStatus.failure;
    }
  }

  Future<List<User>?> importBackup() async {
    if (kDebugMode) print('🔵 Iniciando importación de respaldo...');
    
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al seleccionar archivo: $e");
      }
      return null;
    }

    if (result == null || result.files.isEmpty) {
      if (kDebugMode) print('⚠️ No se seleccionó ningún archivo');
      return null;
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
        if (kDebugMode) print('⚠️ Archivo JSON vacío o inválido');
        return null;
      }

      final backup = json.decode(jsonString);
      if (backup is! Map<String, dynamic> || !backup.containsKey('data')) {
        if (kDebugMode) print('⚠️ Formato de backup inválido');
        return null;
      }

      if (kDebugMode) print('✅ Archivo JSON decodificado correctamente');
      if (kDebugMode) print('📋 Versión del backup: ${backup['version']}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (kDebugMode) print('🧹 Preferencias limpiadas');

      if (kDebugMode) print('🧹 Cerrando y eliminando cajas existentes...');
      for (final boxName in _boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) await Hive.box(boxName).close();
          await Hive.deleteBoxFromDisk(boxName);
        } catch (e) {
          if (kDebugMode) print('⚠️ Advertencia al limpiar la caja $boxName: $e');
        }
      }
      if (kDebugMode) print('✅ Cajas eliminadas');
      
      final prefsData = backup['preferences'] as Map<String, dynamic>? ?? {};
      for (final entry in prefsData.entries) {
        final key = entry.key;
        final value = entry.value;
        try {
          if (value is bool) await prefs.setBool(key, value);
          else if (value is int) await prefs.setInt(key, value);
          else if (value is double) await prefs.setDouble(key, value);
          else if (value is String) await prefs.setString(key, value);
          else if (value is List) await prefs.setStringList(key, value.cast<String>());
        } catch (e) {
          if (kDebugMode) print('Error restaurando preferencia "$key": $e');
        }
      }

      if (kDebugMode) print('📦 Restaurando cajas...');
      final Map<String, dynamic> data = backup['data'];
      
      for (final boxName in _boxNames) {
        if (!_boxNames.contains(boxName)) continue;
        try {
          // Abrir la caja con el tipo correcto para user_box
          final box = boxName == 'user_box' 
              ? await Hive.openBox<User>(boxName)
              : await Hive.openBox(boxName);
          
          final boxData = data[boxName];
          if (boxData is! Map<String, dynamic>) {
            if (kDebugMode) print('⚠️ $boxName: no hay datos o formato inválido');
            continue;
          }
          
          if (kDebugMode) print('📦 Restaurando $boxName: ${boxData.length} registros');
          
          for (final entry in boxData.entries) {
            try {
              final objectToStore = _fromJson(boxName, entry.value);
              if (objectToStore != null) {
                await box.put(entry.key, objectToStore);
                if (boxName == 'user_box' && kDebugMode) {
                  print('  ✓ Usuario guardado con clave: ${entry.key}');
                }
              }
            } catch (e) {
              if (kDebugMode) print('❌ Error restaurando registro "${entry.key}" en "$boxName": $e');
            }
          }
          
          if (boxName == 'user_box' && kDebugMode) {
            print('✅ user_box restaurada: ${box.length} usuarios totales en Hive');
          }
        } catch (e) {
          if (kDebugMode) print('❌ Error crítico restaurando la caja "$boxName": $e');
        }
      }

      final List<User> importedUsers = [];
      final userBoxData = data['user_box'] as Map<String, dynamic>?;
      if (kDebugMode) print('📦 userBoxData keys: ${userBoxData?.keys}');
      
      if (userBoxData != null) {
        for (final userJson in userBoxData.values) {
          try {
            final user = _fromJson('user_box', userJson);
            if (kDebugMode) print('👤 Usuario procesado: ${user is User ? user.name : "null"}');
            if (user is User && !user.isGuest) importedUsers.add(user);
          } catch (e) {
            if (kDebugMode) print('Error converting user from JSON during import: $e');
          }
        }
      }
      
      if (kDebugMode) print('✅ Total usuarios importados: ${importedUsers.length}');
      return importedUsers;

    } catch (e) {
      if (kDebugMode) print('Error decoding or processing the JSON file: $e');
      return null;
    }
  }
}
