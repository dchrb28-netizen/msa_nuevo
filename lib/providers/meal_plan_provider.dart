import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:myapp/models/food.dart';


/// Manages the user's weekly meal plan.
///
/// This provider is responsible for storing, retrieving, and manipulating the
/// planned meals for each day of the week, separating planning from daily logging.
class MealPlanProvider with ChangeNotifier {
  // A map to hold the meal plan for the entire week.
  // The key is the weekday (1=Monday, 7=Sunday).
  // The value is another map where the key is the meal type (e.g., 'Desayuno')
  // and the value is a list of planned foods.
  final Map<int, Map<String, List<Food>>> _weeklyPlan = {
    // Example data for Monday
    1: {
      'Desayuno': [
        Food(id: '1', name: 'Avena con Frutos Rojos', calories: 300, proteins: 10, carbohydrates: 50, fats: 8),
      ],
      'Almuerzo': [
        Food(id: '3', name: 'Pechuga de Pollo a la Plancha', calories: 350, proteins: 50, carbohydrates: 5, fats: 10),
        Food(id: '4', name: 'Ensalada Mixta', calories: 120, proteins: 3, carbohydrates: 12, fats: 6),
      ],
      'Cena': [],
      'Snacks': [],
    },
    // Add other days as needed...
  };

  /// Returns the entire weekly meal plan.
  Map<int, Map<String, List<Food>>> get weeklyPlan => _weeklyPlan;

  /// Returns the planned meals for a specific day and meal type.
  List<Food> getMealsForDay(DateTime day, String mealType) {
    final weekday = day.weekday;
    return _weeklyPlan[weekday]?[mealType] ?? [];
  }

  /// Returns the meal plan for a specific day.
  Map<String, List<Food>> getPlanForDay(DateTime day) {
    final weekday = day.weekday;
    // Ensure all meal types are present, even if empty, for a consistent UI.
    final plan = _weeklyPlan[weekday] ?? {};
    final allMealTypes = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks'];
    for (var mealType in allMealTypes) {
      plan.putIfAbsent(mealType, () => []);
    }
    return plan;
  }

  /// Updates a meal for a specific day and meal type.
  void updateMeal(DateTime day, String mealType, List<Food> newFoods) {
    final weekday = day.weekday;
    if (_weeklyPlan.containsKey(weekday)) {
      _weeklyPlan[weekday]![mealType] = newFoods;
    } else {
      _weeklyPlan[weekday] = {mealType: newFoods};
    }
    notifyListeners();
    // Here you would also add logic to persist this data locally.
  }

  /// Copies the meal plan from the current week to the next week.
  void repeatWeek(DateTime currentWeek) {
    // TODO: Implement logic to copy the plan to the next 7 days.
    // For now, it just notifies listeners as a placeholder.
    developer.log('Función "Repetir Semana" llamada. Lógica pendiente de implementación.', name: 'MealPlanProvider');
    notifyListeners();
  }
}
