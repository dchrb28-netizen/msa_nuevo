import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/streaks_service.dart';

class Meal {
  String description;
  bool isCompleted;

  Meal({this.description = '', this.isCompleted = false});
}

class MealPlanProvider with ChangeNotifier {
  final StreaksService _streaksService = StreaksService();
  final AchievementService _achievementService = AchievementService(); // Instancia del servicio de logros

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

  Map<int, Map<String, Meal>> get weeklyPlan => _weeklyPlan;

  Map<String, Meal> getPlanForDay(DateTime day) {
    final weekday = day.weekday;
    final plan = _weeklyPlan[weekday] ?? {};
    final allMealTypes = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks'];
    for (var mealType in allMealTypes) {
      plan.putIfAbsent(mealType, () => Meal());
    }
    return plan;
  }

  String getMealTextForDay(DateTime day, String mealType) {
    final weekday = day.weekday;
    return _weeklyPlan[weekday]?[mealType]?.description ?? '';
  }

  void updateMealText(DateTime day, String mealType, String newText) {
    final weekday = day.weekday;
    if (_weeklyPlan.containsKey(weekday)) {
      _weeklyPlan[weekday]!.putIfAbsent(mealType, () => Meal());
      _weeklyPlan[weekday]![mealType]!.description = newText;
    } else {
      _weeklyPlan[weekday] = {mealType: Meal(description: newText)};
    }
    notifyListeners();
  }

  void toggleMealCompletion(DateTime day, String mealType) async {
    final weekday = day.weekday;
    final meal = _weeklyPlan[weekday]?[mealType];
    if (meal != null) {
      meal.isCompleted = !meal.isCompleted;
      developer.log(
        'Toggled $mealType for day $weekday to ${meal.isCompleted}',
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
      }

      notifyListeners();
    }
  }

  int _countTotalCompletedMeals() {
    int count = 0;
    _weeklyPlan.forEach((day, meals) {
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
      'Función "Repetir Semana" llamada. Lógica pendiente de implementación.',
      name: 'MealPlanProvider',
    );
    notifyListeners();
  }
}
