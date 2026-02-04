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
import 'package:myapp/models/user_recipe.dart';
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
    'daily_plans',
    'settings',
    'favorite_recipes',
    'user_recipes',
    'reminders',
    'daily_tasks',
    'fasting_logs',
    'routines',
    'routine_logs',
    'exercises',
    'routine_exercises',
    'meal_entries',
    'meditation_logs_json',
    'achievements',
  ];

  /// Obtener caja abierta con el tipo correcto
  Box _getOpenBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw HiveError('La caja $boxName no está abierta');
    }
    
    // Retornar caja tipada según el nombre
    switch (boxName) {
      case 'user_box':
        return Hive.box<User>(boxName);
      case 'foods':
        return Hive.box<Food>(boxName);
      case 'water_logs':
        return Hive.box<WaterLog>(boxName);
      case 'food_logs':
        return Hive.box<FoodLog>(boxName);
      case 'body_measurements':
        return Hive.box<BodyMeasurement>(boxName);
      case 'daily_meal_plans':
        return Hive.box<DailyMealPlan>(boxName);
      case 'favorite_recipes':
        return Hive.box<Recipe>(boxName);
      case 'user_recipes':
        return Hive.box<UserRecipe>(boxName);
      case 'reminders':
        return Hive.box<Reminder>(boxName);
      case 'daily_tasks':
        return Hive.box(boxName); // Caja genérica para daily_tasks
      case 'fasting_logs':
        return Hive.box<FastingLog>(boxName);
      case 'routines':
        return Hive.box<Routine>(boxName);
      case 'routine_logs':
        return Hive.box<RoutineLog>(boxName);
      case 'exercises':
        return Hive.box<Exercise>(boxName);
      case 'routine_exercises':
        return Hive.box<RoutineExercise>(boxName);
      case 'meal_entries':
        return Hive.box<MealEntry>(boxName);
      case 'achievements':
        return Hive.box<Achievement>(boxName);
      case 'meditation_logs_json':
        return Hive.box<String>(boxName);
      case 'profile_data':
      case 'settings':
      case 'daily_plans':
        return Hive.box(boxName); // Cajas genéricas
      default:
        return Hive.box(boxName); // Cajas genéricas
    }
  }

  Future<void> _ensureBoxOpen(String boxName) async {
    if (Hive.isBoxOpen(boxName)) return;
    switch (boxName) {
      case 'user_box':
        await Hive.openBox<User>(boxName);
        break;
      case 'foods':
        await Hive.openBox<Food>(boxName);
        break;
      case 'water_logs':
        await Hive.openBox<WaterLog>(boxName);
        break;
      case 'food_logs':
        await Hive.openBox<FoodLog>(boxName);
        break;
      case 'body_measurements':
        await Hive.openBox<BodyMeasurement>(boxName);
        break;
      case 'daily_meal_plans':
        await Hive.openBox<DailyMealPlan>(boxName);
        break;
      case 'settings':
        await Hive.openBox(boxName);
        break;
      case 'favorite_recipes':
        await Hive.openBox<Recipe>(boxName);
        break;
      case 'user_recipes':
        await Hive.openBox<UserRecipe>(boxName);
        break;
      case 'reminders':
        await Hive.openBox<Reminder>(boxName);
        break;
      case 'daily_tasks':
        await Hive.openBox(boxName);
        break;
      case 'fasting_logs':
        await Hive.openBox<FastingLog>(boxName);
        break;
      case 'routines':
        await Hive.openBox<Routine>(boxName);
        break;
      case 'routine_logs':
        await Hive.openBox<RoutineLog>(boxName);
        break;
      case 'exercises':
        await Hive.openBox<Exercise>(boxName);
        break;
      case 'routine_exercises':
        await Hive.openBox<RoutineExercise>(boxName);
        break;
      case 'meal_entries':
        await Hive.openBox<MealEntry>(boxName);
        break;
      case 'meditation_logs_json':
        await Hive.openBox<String>(boxName);
        break;
      case 'achievements':
        await Hive.openBox<Achievement>(boxName);
        break;
      case 'profile_data':
      case 'daily_plans':
      default:
        await Hive.openBox(boxName);
        break;
    }
  }

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
    'daily_plans': (plan) => plan,
    'favorite_recipes': (recipe) => (recipe as Recipe).toJson(),
    'user_recipes': (recipe) => (recipe as Recipe).toJson(),
    'reminders': (reminder) => (reminder as Reminder).toJson(),
    'daily_tasks': (task) => (task as Map).cast<String, dynamic>(),
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
          // profile_data es una caja genérica, devolver Map directamente
          return Map<String, dynamic>.from(jsonValue);
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
        case 'daily_tasks':
          return Map<String, dynamic>.from(jsonValue);
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
        case 'settings':
          // settings es un box genérico
          return jsonValue;
        default:
          // Fallback para boxes genéricos
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
          // Verificar si la caja está abierta y obtenerla
          if (!Hive.isBoxOpen(boxName)) {
            if (kDebugMode) print('⚠️ La caja $boxName no está abierta. Omitiendo...');
            continue;
          }
          
          final box = _getOpenBox(boxName);
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
          
          if (boxName == 'daily_tasks' && kDebugMode && boxData.isNotEmpty) {
            print('📦 Exportando daily_tasks: ${boxData.length} tareas');
            // Mostrar detalles de tareas repetidas
            int repeatedCount = 0;
            for (final task in boxData.values) {
              if (task is Map && task['repeatType'] != null && task['repeatType'].contains('weekly')) {
                repeatedCount++;
              }
            }
            if (repeatedCount > 0) {
              print('  → ${repeatedCount} tareas repetidas semanales');
            }
          }
          
          if (boxName == 'daily_tasks' && kDebugMode && boxData.isEmpty) {
            print('⚠️ daily_tasks VACÍA (sin tareas para respaldar)');
          }

          if (boxName == 'daily_plans' && kDebugMode) {
            print('📦 Exportando daily_plans: ${boxData.length} registros');
            final plans = boxData['plans'];
            if (plans is Map) {
              print('  → ${plans.length} días con plan');
            }
          }
          
          if (boxName == 'profile_data' && kDebugMode) {
            print('🏆 Exportando profile_data (logros): ${boxData.length} registros');
            final userProfile = boxData['userProfile'];
            if (userProfile is Map) {
              print('  → XP: ${userProfile['experiencePoints']}');
              print('  → Nivel: ${userProfile['level']}');
              print('  → Logros desbloqueados: ${(userProfile['unlockedAchievements'] as Map?)?.length ?? 0}');
              print('  → Progreso de logros: ${(userProfile['achievementProgress'] as Map?)?.length ?? 0}');
            }
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

      if (kDebugMode) {
        print('🔐 Preferencias a respaldar: ${prefsMap.keys.toList()}');
        
        // Mostrar rachas
        final streakKeys = prefsMap.keys.where((k) => k.startsWith('streak_')).toList();
        if (streakKeys.isNotEmpty) {
          print('⚡ Rachas a respaldar: ${streakKeys.length}');
          for (final key in streakKeys) {
            print('  → $key: ${prefsMap[key]}');
          }
        }
        
        // Mostrar temas
        if (prefsMap.containsKey('theme_mode')) print('  → theme_mode: ${prefsMap['theme_mode']}');
        if (prefsMap.containsKey('seed_color')) print('  → seed_color: ${prefsMap['seed_color']}');
      }

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

      if (kDebugMode) print('🧹 Limpiando cajas existentes (sin cerrarlas) para evitar conflictos...');
      for (final boxName in _boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = _getOpenBox(boxName);
            await box.clear();
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Error al limpiar la caja $boxName: $e');
        }
      }
      if (kDebugMode) print('✅ Cajas limpiadas');
      
      final prefsData = backup['preferences'] as Map<String, dynamic>? ?? {};
      if (kDebugMode) print('🔐 Restaurando ${prefsData.length} preferencias...');
      
      // Contar rachas
      final streakKeys = prefsData.keys.where((k) => k.startsWith('streak_')).toList();
      if (kDebugMode && streakKeys.isNotEmpty) {
        print('⚡ Restaurando ${streakKeys.length} rachas...');
      }
      
      for (final entry in prefsData.entries) {
        final key = entry.key;
        final value = entry.value;
        try {
          if (value is bool) await prefs.setBool(key, value);
          else if (value is int) await prefs.setInt(key, value);
          else if (value is double) await prefs.setDouble(key, value);
          else if (value is String) await prefs.setString(key, value);
          else if (value is List) await prefs.setStringList(key, value.cast<String>());
          
          if (kDebugMode) {
            if (key.startsWith('streak_')) {
              print('  ✓ Restaurada racha: $key = $value');
            } else if (key == 'theme_mode' || key == 'seed_color') {
              print('  ✓ Restaurada preferencia: $key = $value');
            }
          }
        } catch (e) {
          if (kDebugMode) print('❌ Error restaurando preferencia "$key": $e');
        }
      }
      if (kDebugMode) print('✅ Preferencias restauradas correctamente');

      if (kDebugMode) print('📦 Restaurando cajas...');
      final Map<String, dynamic> data = backup['data'];
      
      for (final boxName in _boxNames) {
        if (!_boxNames.contains(boxName)) continue;
        try {
          // Verificar si la caja está abierta y obtenerla
          if (!Hive.isBoxOpen(boxName)) {
            try {
              await _ensureBoxOpen(boxName);
            } catch (e) {
              if (kDebugMode) print('⚠️ La caja $boxName no está abierta. Omitiendo... ($e)');
              continue;
            }
          }
          
          final box = _getOpenBox(boxName);
          
          final boxData = data[boxName];
          if (boxData is! Map<String, dynamic>) {
            if (kDebugMode) print('⚠️ $boxName: no hay datos o formato inválido');
            continue;
          }
          
          if (kDebugMode) print('📦 Restaurando $boxName: ${boxData.length} registros');
          
          int successCount = 0;
          final List<Map<String, dynamic>> failedEntries = [];
          for (final entry in boxData.entries) {
            try {
              final objectToStore = _fromJson(boxName, entry.value);
              if (objectToStore != null) {
                await box.put(entry.key, objectToStore);
                successCount++;
                if (boxName == 'user_box' && kDebugMode) {
                  print('  ✓ Usuario guardado con clave: ${entry.key}');
                }
                if (boxName == 'daily_meal_plans' && kDebugMode) {
                  print('  ✓ Plan de comida guardado: ${entry.key}');
                }
                if (boxName == 'profile_data' && entry.key == 'userProfile' && kDebugMode) {
                  final profile = entry.value as Map?;
                  if (profile != null) {
                    print('  🏆 Perfil de logros restaurado:');
                    print('    → XP: ${profile['experiencePoints']}');
                    print('    → Nivel: ${profile['level']}');
                    print('    → Logros desbloqueados: ${(profile['unlockedAchievements'] as Map?)?.length ?? 0}');
                    print('    → Progreso de logros: ${(profile['achievementProgress'] as Map?)?.length ?? 0}');
                  }
                }
              } else {
                if (kDebugMode) print('⚠️ Objeto nulo en $boxName para clave "${entry.key}". Valor original: ${entry.value}');                try {
                  failedEntries.add({'key': entry.key.toString(), 'value': entry.value, 'error': 'null_object'});
                } catch (_) {}              }
            } catch (e) {
              if (kDebugMode) {
                print('❌ Error restaurando registro "${entry.key}" en "$boxName": $e');
                print('   Valor intentado: ${entry.value}');
              }
              // Intentar guardar como valor genérico si falló la deserialización
              try {
                await box.put(entry.key, entry.value);
                successCount++;
                if (kDebugMode) print('   ✓ Guardado como valor genérico');
              } catch (e2) {
                if (kDebugMode) print('   ❌ También falló guardar como genérico: $e2');
                try {
                  failedEntries.add({'key': entry.key.toString(), 'value': entry.value, 'error': e.toString()});
                } catch (_) {}
              }
            }
          }
          
          if (kDebugMode) {
            print('✅ $boxName restaurada: $successCount/${boxData.length} registros');
            if (boxName == 'user_box') {
              print('   Total usuarios en Hive: ${box.length}');
            }
            if (boxName == 'daily_meal_plans') {
              print('   Total planes de comida en Hive: ${box.length}');
            }
            if (failedEntries.isNotEmpty) {
              try {
                final directory = await getTemporaryDirectory();
                final errorFilePath = '${directory.path}/fitflow_restore_errors_${boxName}_${DateTime.now().toIso8601String().replaceAll(':','-')}.json';
                final errorFile = File(errorFilePath);
                await errorFile.writeAsString(const JsonEncoder.withIndent('  ').convert({'box': boxName, 'failed': failedEntries}));
                print('⚠️ Se encontraron registros que no se pudieron restaurar para $boxName. Archivo de diagnóstico: $errorFilePath');
              } catch (e) {
                print('⚠️ No se pudo escribir archivo de diagnóstico para $boxName: $e');
              }
            }
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
