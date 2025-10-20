import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/food.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealType;
  final DateTime date;

  const MealDetailScreen({super.key, required this.mealType, required this.date});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final List<Food> foods = [
      Food(id: '1', name: 'Tostada con Aguacate', calories: 250, proteins: 8, carbohydrates: 25, fats: 15),
      Food(id: '2', name: 'Huevo Cocido', calories: 78, proteins: 6, carbohydrates: 0.6, fats: 5),
    ];

    final totalCalories = foods.fold(0.0, (sum, food) => sum + food.calories);
    final totalProteins = foods.fold(0.0, (sum, food) => sum + food.proteins);
    final totalCarbs = foods.fold(0.0, (sum, food) => sum + food.carbohydrates);
    final totalFats = foods.fold(0.0, (sum, food) => sum + food.fats);

    return Scaffold(
      appBar: AppBar(
        title: Text('$mealType - ${date.day}/${date.month}/${date.year}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alimentos:', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
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
                      subtitle: Text('${food.calories.toStringAsFixed(0)} kcal'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('P: ${food.proteins.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Text('C: ${food.carbohydrates.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Text('G: ${food.fats.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 30, thickness: 1),
            _buildTotalMacros(totalCalories, totalProteins, totalCarbs, totalFats),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalMacros(double calories, double proteins, double carbs, double fats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen Nutricional:', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _macroPill('Calorías', '${calories.toStringAsFixed(0)} kcal', Colors.orange),
            _macroPill('Proteínas', '${proteins.toStringAsFixed(1)}g', Colors.green),
            _macroPill('Carbs', '${carbs.toStringAsFixed(1)}g', Colors.blue),
            _macroPill('Grasas', '${fats.toStringAsFixed(1)}g', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _macroPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(value, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }
}
