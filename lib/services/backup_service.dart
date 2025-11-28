import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Exportar todos los datos a un archivo JSON
  Future<String?> exportBackup() async {
    try {
      final Map<String, dynamic> backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
        'data': {},
        'preferences': {},
      };

      // Lista de todas las cajas de Hive a respaldar
      final boxNames = [
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

      // Exportar cada caja
      for (final boxName in boxNames) {
        try {
          final box = await Hive.openBox(boxName);
          final Map<String, dynamic> boxData = {};
          
          for (final key in box.keys) {
            final value = box.get(key);
            // Convertir a formato serializable
            if (value != null) {
              boxData[key.toString()] = _serializeValue(value);
            }
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
          final value = prefs.get(key);
          if (value != null) {
            prefsMap[key] = value;
          }
        }
        backup['preferences'] = prefsMap;
      } catch (e) {
        if (kDebugMode) {
          print('Error al exportar preferencias: $e');
        }
      }

      // Crear archivo JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      
      if (kIsWeb) {
        // En web, retornar el JSON como string para descargar
        return jsonString;
      } else {
        // En móvil, guardar en ubicación elegida por el usuario
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'backup_myapp_$timestamp.json';
        
        // Usar file_picker para que el usuario elija dónde guardar
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
    try {
      String? jsonString;
      
      if (kIsWeb) {
        // En web, usar file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        
        if (result != null && result.files.isNotEmpty) {
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            jsonString = utf8.decode(bytes);
          }
        }
      } else {
        // En móvil, usar file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        
        if (result != null && result.files.isNotEmpty) {
          final path = result.files.first.path;
          if (path != null) {
            final file = File(path);
            jsonString = await file.readAsString();
          }
        }
      }
      
      if (jsonString == null) return false;
      
      // Parsear JSON
      final Map<String, dynamic> backup = json.decode(jsonString);
      final Map<String, dynamic> data = backup['data'] as Map<String, dynamic>;
      
      // Restaurar cada caja
      for (final entry in data.entries) {
        try {
          final boxName = entry.key;
          final boxData = entry.value as Map<String, dynamic>;
          
          // Abrir la caja con el tipo correcto
          Box box;
          if (boxName == 'user_box') {
            box = await Hive.openBox('user_box');
          } else if (boxName == 'profile_data') {
            box = await Hive.openBox('profile_data');
          } else {
            box = await Hive.openBox(boxName);
          }
          
          // NO limpiar user_box ni profile_data si están vacíos en el backup
          // Solo limpiar si hay datos para restaurar
          if (boxData.isNotEmpty) {
            await box.clear();
            
            // Restaurar datos
            for (final dataEntry in boxData.entries) {
              try {
                final key = dataEntry.key;
                final value = dataEntry.value;
                
                // Para user_box y profile_data, restaurar el mapa completo
                // Hive lo reconstruirá automáticamente si los adaptadores están registrados
                await box.put(key, value);
              } catch (e) {
                if (kDebugMode) {
                  print('Error al restaurar entrada $dataEntry.key en $boxName: $e');
                }
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error al restaurar caja ${entry.key}: $e');
          }
        }
      }

      // Restaurar SharedPreferences
      if (backup.containsKey('preferences')) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final prefsData = backup['preferences'] as Map<String, dynamic>;
          
          for (final entry in prefsData.entries) {
            final key = entry.key;
            final value = entry.value;
            
            if (value is bool) {
              await prefs.setBool(key, value);
            } else if (value is int) {
              await prefs.setInt(key, value);
            } else if (value is double) {
              await prefs.setDouble(key, value);
            } else if (value is String) {
              await prefs.setString(key, value);
            } else if (value is List<String>) {
              await prefs.setStringList(key, value);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error al restaurar preferencias: $e');
          }
        }
      }
      // Forzar escritura de todos los datos a disco y reinicializar
      await Hive.close();
      await Hive.initFlutter();
      
      // Reabrir las cajas necesarias
      await Hive.openBox('user_box');
      await Hive.openBox('profile_data');
      await Hive.openBox('foods');
      await Hive.openBox('water_logs');
      await Hive.openBox('food_logs');
      await Hive.openBox('body_measurements');
      await Hive.openBox('daily_meal_plans');
      await Hive.openBox('settings');
      await Hive.openBox('favorite_recipes');
      await Hive.openBox('user_recipes');
      await Hive.openBox('reminders');
      await Hive.openBox('fasting_logs');
      await Hive.openBox('routines');
      await Hive.openBox('routine_logs');
      await Hive.openBox('exercises');
      await Hive.openBox('routine_exercises');
      await Hive.openBox('meal_entries');
      await Hive.openBox('meditation_logs_json');
      
      if (kDebugMode) {
        print('✅ Respaldo restaurado exitosamente');
        print('📦 Cajas restauradas: ${data.keys.length}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al importar respaldo: $e');
      }
      return false;
    }
  }

  /// Serializar un valor para JSON
  dynamic _serializeValue(dynamic value) {
    if (value == null) return null;
    if (value is String || value is num || value is bool) return value;
    if (value is List) return value.map(_serializeValue).toList();
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _serializeValue(v)));
    }
    // Para objetos complejos, intentar convertir a Map
    try {
      if (value is Map) return value;
      return value.toString();
    } catch (e) {
      return value.toString();
    }
  }

  /// Deserializar un valor desde JSON
  dynamic _deserializeValue(dynamic value) {
    // JSON ya deserializa correctamente tipos básicos
    return value;
  }

  /// Obtener tamaño estimado del respaldo
  Future<int> getEstimatedBackupSize() async {
    try {
      int totalSize = 0;
      
      final boxNames = [
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

      for (final boxName in boxNames) {
        try {
          final box = await Hive.openBox(boxName);
          totalSize += box.length;
        } catch (e) {
          // Ignorar errores
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
