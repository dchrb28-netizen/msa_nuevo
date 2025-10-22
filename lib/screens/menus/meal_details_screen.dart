import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:provider/provider.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealType;
  final DateTime date;

  const MealDetailScreen({super.key, required this.mealType, required this.date});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, mealPlanProvider, child) {
        final foods = mealPlanProvider.getMealsForDay(date, mealType);

        final totalCalories = foods.fold(0.0, (sum, food) => sum + (food.calories ?? 0));
        final totalProteins = foods.fold(0.0, (sum, food) => sum + (food.proteins ?? 0));
        final totalCarbs = foods.fold(0.0, (sum, food) => sum + (food.carbohydrates ?? 0));
        final totalFats = foods.fold(0.0, (sum, food) => sum + (food.fats ?? 0));
        final formattedDate = DateFormat('d MMMM y', 'es_ES').format(date);

        return Scaffold(
          appBar: AppBar(
            title: Text('$mealType - $formattedDate'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alimentos Planificados:', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (foods.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No hay alimentos planificados para esta comida.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(food.name, style: GoogleFonts.lato(fontWeight: FontWeight.w500)),
                            subtitle: Text('${(food.calories ?? 0).toStringAsFixed(0)} kcal'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('P: ${(food.proteins ?? 0).toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12, color: Colors.green)),
                                const SizedBox(width: 8),
                                Text('C: ${(food.carbohydrates ?? 0).toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                                const SizedBox(width: 8),
                                Text('G: ${(food.fats ?? 0).toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12, color: Colors.red)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const Divider(height: 30, thickness: 1),
                _buildTotalMacros(context, totalCalories, totalProteins, totalCarbs, totalFats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalMacros(BuildContext context, double calories, double proteins, double carbs, double fats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen Nutricional Total:', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _macroPill('Calorías', calories.toStringAsFixed(0), 'kcal', Colors.orange),
            _macroPill('Proteínas', proteins.toStringAsFixed(1), 'g', Colors.green),
            _macroPill('Carbs', carbs.toStringAsFixed(1), 'g', Colors.blue),
            _macroPill('Grasas', fats.toStringAsFixed(1), 'g', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _macroPill(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(100)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 4),
              Text(unit, style: GoogleFonts.lato(fontSize: 12, color: color)),
            ],
          ),
        ),
      ],
    );
  }
}
