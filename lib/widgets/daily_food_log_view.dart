import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';

class DailyFoodLogView extends StatelessWidget {
  final DateTime date;
  final double? calorieGoal;
  final String? dietPlan;

  const DailyFoodLogView({
    super.key,
    required this.date,
    this.calorieGoal,
    this.dietPlan,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        final dailyLogs = box.values.where((log) => DateUtils.isSameDay(log.timestamp, date)).toList();

        final Map<String, List<FoodLog>> groupedLogs = {};
        for (var log in dailyLogs) {
          (groupedLogs[log.mealType] ??= []).add(log);
        }

        final mealOrder = ['Desayuno', 'Almuerzo', 'Cena', 'Snack'];
        final sortedGroupedLogs = Map.fromEntries(
            mealOrder.where((meal) => groupedLogs.containsKey(meal)).map((meal) => MapEntry(meal, groupedLogs[meal]!)));

        final totalCalories = dailyLogs.fold<double>(0, (sum, log) => sum + ((log.food.calories ?? 0) * log.quantity / 100));
        final totalProteins = dailyLogs.fold<double>(0, (sum, log) => sum + ((log.food.proteins ?? 0) * log.quantity / 100));
        final totalCarbs = dailyLogs.fold<double>(0, (sum, log) => sum + ((log.food.carbohydrates ?? 0) * log.quantity / 100));
        final totalFats = dailyLogs.fold<double>(0, (sum, log) => sum + ((log.food.fats ?? 0) * log.quantity / 100));

        return Column(
          children: [
            _buildNutritionSummary(context, totalCalories, totalProteins, totalCarbs, totalFats),
            const SizedBox(height: 10),
            Expanded(
              child: dailyLogs.isEmpty
                  ? const Center(child: Text('No hay comidas registradas para esta fecha.'))
                  : ListView.builder(
                      itemCount: sortedGroupedLogs.keys.length,
                      itemBuilder: (context, index) {
                        final mealType = sortedGroupedLogs.keys.elementAt(index);
                        final logsForMeal = sortedGroupedLogs[mealType]!;
                        final mealCalories = logsForMeal.fold<double>(
                            0, (sum, log) => sum + ((log.food.calories ?? 0) * log.quantity / 100));

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        _getMealIcon(mealType),
                                        const SizedBox(width: 8),
                                        Text(mealType, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Text('${mealCalories.toInt()} kcal',
                                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: colorScheme.secondary)),
                                  ],
                                ),
                              ),
                              const Divider(indent: 16, endIndent: 16),
                              ...logsForMeal.map((log) {
                                return ListTile(
                                  title: Text(log.food.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  subtitle: Text('${log.quantity}g'),
                                  trailing: Text('${((log.food.calories ?? 0) * log.quantity / 100).toInt()} kcal'),
                                  onLongPress: () => log.delete(),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNutritionSummary(BuildContext context, double calories, double proteins, double carbs, double fats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildCalorieEquation(context, calories),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nutritionIndicator('Proteínas', proteins.toInt().toString(), 'g', Colors.green),
              _nutritionIndicator('Carbs', carbs.toInt().toString(), 'g', Colors.blue),
              _nutritionIndicator('Grasas', fats.toInt().toString(), 'g', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieEquation(BuildContext context, double consumedCalories) {
    final textTheme = Theme.of(context).textTheme;
    final remainingCalories = (calorieGoal ?? 0) - consumedCalories;
    final planDisplayName = _getPlanDisplayName(dietPlan);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          children: [
            if (planDisplayName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Plan: $planDisplayName',
                   style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _calorieComponent('Meta', (calorieGoal ?? 0).toInt(), textTheme, isGoal: true),
                const Text('-', style: TextStyle(fontSize: 28)),
                _calorieComponent('Consumidas', consumedCalories.toInt(), textTheme),
                const Text('=', style: TextStyle(fontSize: 28)),
                _calorieComponent('Restantes', remainingCalories.toInt(), textTheme, isRemaining: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _getPlanDisplayName(String? plan) {
    switch (plan) {
      case 'Perder':
        return 'Pérdida de Peso';
      case 'Mantener':
        return 'Mantenimiento';
      case 'Ganar':
        return 'Aumento de Masa';
      case 'Personalizado':
        return 'Personalizado';
      default:
        return null;
    }
  }

  Widget _calorieComponent(String label, int value, TextTheme textTheme, {bool isGoal = false, bool isRemaining = false}) {
    Color valueColor = isRemaining ? (value < 0 ? Colors.red.shade400 : Colors.green.shade400) : (isGoal ? Colors.orange.shade400 : Colors.blue.shade400);
    
    return Column(
      children: [
        Text(
          value.toString(),
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: valueColor),
        ),
        const SizedBox(height: 2),
        Text(label, style: textTheme.labelLarge),
      ],
    );
  }

  Widget _nutritionIndicator(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(unit, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Icon _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Desayuno':
        return Icon(Icons.free_breakfast, color: Colors.orange.shade700);
      case 'Almuerzo':
        return Icon(Icons.lunch_dining, color: Colors.red.shade700);
      case 'Cena':
        return Icon(Icons.dinner_dining, color: Colors.purple.shade700);
      case 'Snack':
        return Icon(Icons.fastfood, color: Colors.blue.shade700);
      default:
        return Icon(Icons.restaurant, color: Colors.grey.shade700);
    }
  }
}
