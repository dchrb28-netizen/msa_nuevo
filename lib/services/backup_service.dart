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
        // En móvil, guardar en archivo temporal
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${directory.path}/backup_$timestamp.json');
        await file.writeAsString(jsonString);
        
        // Compartir el archivo
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Respaldo MyApp',
          text: 'Respaldo de datos de MyApp',
        );
        
        return file.path;
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
          
          // Abrir o obtener la caja existente
          Box box;
          try {
            // Intentar obtener la caja si ya está abierta
            box = Hive.box(boxName);
          } catch (e) {
            // Si no está abierta, abrirla
            box = await Hive.openBox(boxName);
          }
          
          // Solo limpiar y restaurar si hay datos
          if (boxData.isNotEmpty) {
            await box.clear();
            
            // Restaurar datos
            for (final dataEntry in boxData.entries) {
              try {
                dynamic key = dataEntry.key;
                var value = dataEntry.value;
                
                // Si la key es un número string, convertirla a int
                if (key is String && int.tryParse(key) != null) {
                  key = int.parse(key);
                }
                
                // Guardar el valor - Hive reconstruirá los objetos usando los adapters
                await box.put(key, value);
              } catch (e) {
                if (kDebugMode) {
                  print('Error al restaurar entrada ${dataEntry.key} en $boxName: $e');
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
      
      // NO cerrar Hive aquí porque causaría que las cajas no estén disponibles
      // Las cajas ya están abiertas y actualizadas con los nuevos datos
      // Hive sincroniza automáticamente los cambios al disco
      
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
