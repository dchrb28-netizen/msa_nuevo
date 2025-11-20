import 'dart:developer' as developer;
import 'package:flutter/material.dart';

// A simple class to hold the meal's data
class Meal {
  String description;
  bool isCompleted;

  Meal({this.description = '', this.isCompleted = false});
}

class MealPlanProvider with ChangeNotifier {
  // The data structure is now a map of Meals
  final Map<int, Map<String, Meal>> _weeklyPlan = {
    1: {
      'Desayuno': Meal(description: 'Avena con Frutos Rojos'),
      'Almuerzo': Meal(
        description: 'Pechuga de Pollo a la Plancha, Ensalada Mixta',
      ),
      'Cena': Meal(),
      'Snacks': Meal(),
    },
    2: {
      'Desayuno': Meal(),
      'Almuerzo': Meal(),
      'Cena': Meal(),
      'Snacks': Meal(),
    },
    3: {
      'Desayuno': Meal(),
      'Almuerzo': Meal(),
      'Cena': Meal(),
      'Snacks': Meal(),
    },
    4: {
      'Desayuno': Meal(),
      'Almuerzo': Meal(),
      'Cena': Meal(),
      'Snacks': Meal(),
    },
    5: {
      'Desayuno': Meal(),
      'Almuerzo': Meal(),
      'Cena': Meal(),
      'Snacks': Meal(),
    },
    6: {
      'Desayuno': Meal(),
      'Almuerzo': Meal(),
      'Cena': Meal(),
      'Snacks': Meal(),
    },
    7: {
      'Desayuno': Meal(),
      'Almuerzo': Meal(),
      'Cena': Meal(),
      'Snacks': Meal(),
    },
  };

  Map<int, Map<String, Meal>> get weeklyPlan => _weeklyPlan;

  // Returns the full Meal object map for a given day
  Map<String, Meal> getPlanForDay(DateTime day) {
    final weekday = day.weekday;
    final plan = _weeklyPlan[weekday] ?? {};
    final allMealTypes = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks'];
    for (var mealType in allMealTypes) {
      plan.putIfAbsent(mealType, () => Meal());
    }
    return plan;
  }

  // Still needed for the edit screen, returns only the text
  String getMealTextForDay(DateTime day, String mealType) {
    final weekday = day.weekday;
    return _weeklyPlan[weekday]?[mealType]?.description ?? '';
  }

  // Updates the description of a meal
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

  // --- NEW FUNCTIONALITY ---
  // Toggles the completion status of a meal
  void toggleMealCompletion(DateTime day, String mealType) {
    final weekday = day.weekday;
    final meal = _weeklyPlan[weekday]?[mealType];
    if (meal != null) {
      meal.isCompleted = !meal.isCompleted;
      developer.log(
        'Toggled $mealType for day $weekday to ${meal.isCompleted}',
        name: 'MealPlanProvider',
      );
      notifyListeners();
    }
  }
  // --- END NEW FUNCTIONALITY ---

  void repeatWeek(DateTime currentWeek) {
    developer.log(
      'Función "Repetir Semana" llamada. Lógica pendiente de implementación.',
      name: 'MealPlanProvider',
    );
    notifyListeners();
  }
}
