import 'dart:developer' as developer;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/streaks_service.dart';
import 'package:myapp/services/meal_nutrition_service.dart';
import 'package:myapp/models/food_log.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:myapp/services/task_notification_service.dart';

// Persistencia de planes por fecha en Hive bajo la caja 'daily_plans'

class Meal {
  String description;
  bool isCompleted;

  Meal({this.description = '', this.isCompleted = false});
}

class MealPlanProvider with ChangeNotifier {
  final StreaksService _streaksService = StreaksService();
  final AchievementService _achievementService = AchievementService(); // Instancia del servicio de logros

  MealPlanProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      if (!Hive.isBoxOpen('daily_plans')) {
        await Hive.openBox('daily_plans');
      }
      _loadDailyPlan();
      // Inicializar servicio de notificaciones y temporizador
      try {
        await TaskNotificationService().init();
        _startNotificationTimer();
      } catch (_) {}
      // El timer de notificaciones se ha deshabilitado por solicitud del usuario
      // No se enviarán notificaciones de comidas pendientes
      // _startNotificationTimer();
    } catch (_) {
      // fallback silencioso
    }
  }

  Timer? _notificationTimer;
  final int _notificationIntervalMinutes = 60; // intervalo por defecto

  void _startNotificationTimer() {
    _stopNotificationTimer();
    _notificationTimer = Timer.periodic(Duration(minutes: _notificationIntervalMinutes), (_) {
      _checkAndNotifyPendingTasks();
    });
  }

  void _stopNotificationTimer() {
    try {
      _notificationTimer?.cancel();
      _notificationTimer = null;
    } catch (_) {}
  }

  void _checkAndNotifyPendingTasks() async {
    try {
      // Contar tareas diarias pendientes solo del día actual
      final dailyTasksPending = await TaskNotificationService().getPendingTasksCountForToday();

      // Solo mostrar notificación si hay tareas diarias pendientes
      if (dailyTasksPending > 0) {
        TaskNotificationService().showPendingTasksNotification(dailyTasksPending);
      }
    } catch (_) {}
  }

  void _loadDailyPlan() {
    try {
      final box = Hive.box('daily_plans');
      final data = box.get('plans');
      if (data is Map) {
        _dailyPlan.clear();
        data.forEach((date, meals) {
          if (meals is Map) {
            final map = <String, Meal>{};
            meals.forEach((mt, m) {
              if (m is Map) {
                final desc = m['description']?.toString() ?? '';
                final completed = m['isCompleted'] == true;
                map[mt.toString()] = Meal(description: desc, isCompleted: completed);
              }
            });
            _dailyPlan[date.toString()] = map;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> reloadFromStorage() async {
    try {
      if (!Hive.isBoxOpen('daily_plans')) {
        await Hive.openBox('daily_plans');
      }
      _loadDailyPlan();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveDailyPlan() async {
    try {
      if (!Hive.isBoxOpen('daily_plans')) {
        await Hive.openBox('daily_plans');
      }
      final box = Hive.box('daily_plans');
      final serial = <String, Map<String, Map<String, dynamic>>>{};
      _dailyPlan.forEach((date, meals) {
        final m = <String, Map<String, dynamic>>{};
        meals.forEach((mt, meal) {
          m[mt] = {
            'description': meal.description,
            'isCompleted': meal.isCompleted,
          };
        });
        serial[date] = m;
      });
      await box.put('plans', serial);
    } catch (_) {}
  }

  final Map<int, Map<String, Meal>> _weeklyPlan = {
    1: {
      'Desayuno': Meal(description: 'Avena con Frutos Rojos'),
      'Almuerzo': Meal(description: 'Pechuga de Pollo a la Plancha, Ensalada Mixta'),
      'Cena': Meal(), 'Snacks': Meal(),
    },
    2: {'Desayuno': Meal(), 'Almuerzo': Meal(), 'Cena': Meal(), 'Snacks': Meal()},
    3: {'Desayuno': Meal(), 'Almuerzo': Meal(), 'Cena': Meal(), 'Snacks': Meal()},
    4: {'Desayuno': Meal(), 'Almuerzo': Meal(), 'Cena': Meal(), 'Snacks': Meal()},
    5: {'Desayuno': Meal(), 'Almuerzo': Meal(), 'Cena': Meal(), 'Snacks': Meal()},
    6: {'Desayuno': Meal(), 'Almuerzo': Meal(), 'Cena': Meal(), 'Snacks': Meal()},
    7: {'Desayuno': Meal(), 'Almuerzo': Meal(), 'Cena': Meal(), 'Snacks': Meal()},
  };

  // Planes específicos por fecha (clave: YYYY-MM-DD)
  final Map<String, Map<String, Meal>> _dailyPlan = {};
  // Pila para deshacer operaciones (snapshots serializados)
  final List<Map<String, Map<String, Map<String, dynamic>>>> _undoStack = [];

  Map<int, Map<String, Meal>> get weeklyPlan => _weeklyPlan;

  Map<String, Meal> getPlanForDay(DateTime day) {
    final key = _keyForDate(day);

    if (_dailyPlan.containsKey(key)) {
      return _dailyPlan[key]!;
    }

    // Crear una copia basada en la plantilla semanal para permitir ediciones por fecha
    final weekday = day.weekday;
    final template = _weeklyPlan[weekday] ?? {};
    final allMealTypes = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks'];
    final plan = <String, Meal>{};
    for (var mealType in allMealTypes) {
      final t = template[mealType];
      plan[mealType] = Meal(description: t?.description ?? '', isCompleted: false);
    }

    // No persistimos automáticamente hasta que el usuario modifique algo
    return plan;
  }

  String getMealTextForDay(DateTime day, String mealType) {
    final key = _keyForDate(day);
    if (_dailyPlan.containsKey(key)) {
      return _dailyPlan[key]?[mealType]?.description ?? '';
    }

    final weekday = day.weekday;
    return _weeklyPlan[weekday]?[mealType]?.description ?? '';
  }

  void updateMealText(DateTime day, String mealType, String newText) {
    final key = _keyForDate(day);

    // Ensure a daily plan exists (create from weekly template if necessary)
    if (!_dailyPlan.containsKey(key)) {
      final weekday = day.weekday;
      final template = _weeklyPlan[weekday] ?? {};
      final map = <String, Meal>{};
      final allMealTypes = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks'];
      for (var mt in allMealTypes) {
        final t = template[mt];
        map[mt] = Meal(description: t?.description ?? '', isCompleted: false);
      }
      _dailyPlan[key] = map;
    }

    _dailyPlan[key]!.putIfAbsent(mealType, () => Meal());
    _dailyPlan[key]![mealType]!.description = newText;
    notifyListeners();
    // Persistir cambios
    _saveDailyPlan();
  }

  void toggleMealCompletion(DateTime day, String mealType) async {
    final key = _keyForDate(day);

    // Ensure daily plan exists so completion is stored per-date
    if (!_dailyPlan.containsKey(key)) {
      updateMealText(day, mealType, getMealTextForDay(day, mealType));
    }

    final meal = _dailyPlan[key]?[mealType];
    if (meal != null) {
      meal.isCompleted = !meal.isCompleted;
      developer.log(
        'Toggled $mealType for day ${day.weekday} to ${meal.isCompleted}',
        name: 'MealPlanProvider',
      );
      
      if (meal.isCompleted) {
        // Otorga XP por completar una comida
        _achievementService.grantExperience(10);

        // Actualiza logros relevantes
        _achievementService.updateProgress('first_meal', 1);

        final totalMeals = _countTotalCompletedMeals();
        _achievementService.updateProgress('cum_meals_500', totalMeals, cumulative: true);
        
        // Actualiza la racha de comidas
        await _streaksService.updateMealStreak();

        // Guardar automáticamente en food_logs como comida consumida
        try {
          final nutrition = await MealNutritionService.getNutritionForMeal(meal.description);
          final box = Hive.box<FoodLog>('food_logs');

          // Evitar duplicados: buscar un registro para la misma fecha, tipo y nombre
          final exists = box.values.any((log) {
            return log.mealType == mealType &&
                log.date.year == day.year &&
                log.date.month == day.month &&
                log.date.day == day.day &&
                log.foodName == meal.description;
          });

          if (!exists) {
            final id = const Uuid().v4();
            final newLog = FoodLog(
              id: id,
              foodName: meal.description,
              calories: nutrition?.calories ?? 0.0,
              protein: nutrition?.protein ?? 0.0,
              carbohydrates: nutrition?.carbs ?? 0.0,
              fat: nutrition?.fat ?? 0.0,
              date: day,
              mealType: mealType,
            );

            await box.add(newLog);
          }
        } catch (e) {
          // Ignorar errores al guardar nutrición
        }
      } else {
        // Si la comida fue desmarcada como completada, eliminar los FoodLog asociados
        try {
          final box = Hive.box<FoodLog>('food_logs');
          final toRemove = box.values.where((log) {
            return log.mealType == mealType &&
                log.date.year == day.year &&
                log.date.month == day.month &&
                log.date.day == day.day &&
                log.foodName == meal.description;
          }).toList();

          for (final log in toRemove) {
            try {
              await log.delete();
            } catch (_) {
              // ignore individual delete errors
            }
          }
        } catch (e) {
          // Ignorar errores al eliminar registros
        }
      }

      notifyListeners();
      // Persistir cambios
      _saveDailyPlan();
    }
  }

  int _countTotalCompletedMeals() {
    int count = 0;
    _dailyPlan.forEach((day, meals) {
      meals.forEach((mealType, meal) {
        if (meal.isCompleted) {
          count++;
        }
      });
    });
    return count;
  }

  void repeatWeek(DateTime currentWeek) {
    developer.log(
      'Función "Repetir Semana" llamada. Use repeatWeek(source,target) en su lugar.',
      name: 'MealPlanProvider',
    );
    notifyListeners();
    // Persistir cambios
    _saveDailyPlan();
  }

  /// Copiar los planes de una semana fuente a una semana objetivo.
  /// `sourceWeekStart` y `targetWeekStart` deben ser fechas que representen el lunes de cada semana.
  void repeatWeekDates(DateTime sourceWeekStart, DateTime targetWeekStart, {bool overwrite = true}) {
    // Guardar snapshot para permitir deshacer
    final snapshot = <String, Map<String, Map<String, dynamic>>>{};
    _dailyPlan.forEach((date, meals) {
      final m = <String, Map<String, dynamic>>{};
      meals.forEach((mt, meal) {
        m[mt] = {'description': meal.description, 'isCompleted': meal.isCompleted};
      });
      snapshot[date] = m;
    });
    _undoStack.add(snapshot);

    final allMealTypes = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks'];

    for (int i = 0; i < 7; i++) {
      final sourceDate = DateTime(sourceWeekStart.year, sourceWeekStart.month, sourceWeekStart.day).add(Duration(days: i));
      final targetDate = DateTime(targetWeekStart.year, targetWeekStart.month, targetWeekStart.day).add(Duration(days: i));
      final sourcePlan = getPlanForDay(sourceDate);
      final targetKey = _keyForDate(targetDate);

      // Construir mapa objetivo
      final targetMap = <String, Meal>{};
      for (var mt in allMealTypes) {
        final desc = sourcePlan[mt]?.description ?? '';
        targetMap[mt] = Meal(description: desc, isCompleted: false);
      }

      if (overwrite || !_dailyPlan.containsKey(targetKey)) {
        _dailyPlan[targetKey] = targetMap;
      } else {
        final existing = _dailyPlan[targetKey]!;
        for (var mt in allMealTypes) {
          if ((existing[mt]?.description ?? '').isEmpty) {
            existing[mt] = targetMap[mt]!;
          }
        }
      }
    }

    notifyListeners();
  }

  String _keyForDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Deshacer la última operación que modificó `_dailyPlan` (si hay snapshot)
  void undoLastChange() {
    if (_undoStack.isEmpty) return;
    final snap = _undoStack.removeLast();
    _dailyPlan.clear();
    snap.forEach((date, meals) {
      final map = <String, Meal>{};
      meals.forEach((mt, m) {
        final desc = m['description']?.toString() ?? '';
        final completed = m['isCompleted'] == true;
        map[mt] = Meal(description: desc, isCompleted: completed);
      });
      _dailyPlan[date] = map;
    });
    notifyListeners();
    _saveDailyPlan();
  }

  @override
  void dispose() {
    _stopNotificationTimer();
    super.dispose();
  }

  /// Exportar `_dailyPlan` como JSON string
  String exportDailyPlanJson() {
    final serial = <String, Map<String, Map<String, dynamic>>>{};
    _dailyPlan.forEach((date, meals) {
      final m = <String, Map<String, dynamic>>{};
      meals.forEach((mt, meal) {
        m[mt] = {
          'description': meal.description,
          'isCompleted': meal.isCompleted,
        };
      });
      serial[date] = m;
    });
    try {
      return const JsonEncoder.withIndent('  ').convert(serial);
    } catch (_) {
      return '{}';
    }
  }

  /// Importar JSON para `_dailyPlan`. Si `overwrite` es true, reemplaza; si false, mezcla rellenando vacíos.
  void importDailyPlanJson(String jsonStr, {bool overwrite = true}) {
    try {
      final decoded = const JsonDecoder().convert(jsonStr);
      if (decoded is Map) {
        final incoming = <String, Map<String, Map<String, dynamic>>>{};
        decoded.forEach((date, meals) {
          if (meals is Map) {
            final m = <String, Map<String, dynamic>>{};
            meals.forEach((mt, mm) {
              if (mm is Map) {
                m[mt.toString()] = {
                  'description': mm['description']?.toString() ?? '',
                  'isCompleted': mm['isCompleted'] == true,
                };
              }
            });
            incoming[date.toString()] = m;
          }
        });

        // Guardar snapshot previo para undo
        final snapshot = <String, Map<String, Map<String, dynamic>>>{};
        _dailyPlan.forEach((date, meals) {
          final mm = <String, Map<String, dynamic>>{};
          meals.forEach((mt, meal) {
            mm[mt] = {'description': meal.description, 'isCompleted': meal.isCompleted};
          });
          snapshot[date] = mm;
        });
        _undoStack.add(snapshot);

        // Aplicar incoming
        incoming.forEach((date, meals) {
          if (overwrite || !_dailyPlan.containsKey(date)) {
            final map = <String, Meal>{};
            meals.forEach((mt, m) {
              map[mt] = Meal(description: m['description']?.toString() ?? '', isCompleted: m['isCompleted'] == true);
            });
            _dailyPlan[date] = map;
          } else if (!overwrite) {
            final existing = _dailyPlan[date]!;
            meals.forEach((mt, m) {
              if ((existing[mt]?.description ?? '').isEmpty) {
                existing[mt] = Meal(description: m['description']?.toString() ?? '', isCompleted: m['isCompleted'] == true);
              }
            });
          }
        });

        notifyListeners();
        _saveDailyPlan();
      }
    } catch (_) {
      // ignore parse errors
    }
  }
}
