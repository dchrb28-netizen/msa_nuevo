import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class TodayMenuScreen extends StatelessWidget {
  const TodayMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Dummy data for demonstration
    final Map<String, List<Food>> dailyMenu = {
      'Desayuno': [
        Food(id: '1', name: 'Tostada con Aguacate', calories: 250, proteins: 8, carbohydrates: 25, fats: 15),
        Food(id: '2', name: 'Huevo Cocido', calories: 78, proteins: 6, carbohydrates: 0.6, fats: 5),
      ],
      'Almuerzo': [
        Food(id: '3', name: 'Pechuga de Pollo a la Plancha', calories: 350, proteins: 50, carbohydrates: 5, fats: 10),
        Food(id: '4', name: 'Ensalada Verde', calories: 100, proteins: 2, carbohydrates: 10, fats: 5),
        Food(id: '5', name: 'Quinoa', calories: 120, proteins: 4, carbohydrates: 21, fats: 2),
      ],
      'Cena': [
        Food(id: '6', name: 'Salmón al Horno', calories: 400, proteins: 40, carbohydrates: 0, fats: 25),
        Food(id: '7', name: 'Brócoli al Vapor', calories: 55, proteins: 3.7, carbohydrates: 11, fats: 0.6),
      ],
      'Snacks': [
        Food(id: '8', name: 'Yogur Griego', calories: 150, proteins: 15, carbohydrates: 10, fats: 5),
        Food(id: '9', name: 'Puñado de Almendras', calories: 160, proteins: 6, carbohydrates: 6, fats: 14),
      ],
    };

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: dailyMenu.keys.length,
        itemBuilder: (context, index) {
          final mealType = dailyMenu.keys.elementAt(index);
          final foods = dailyMenu[mealType]!;
          final totalCalories = foods.fold(0.0, (sum, food) => sum + food.calories);

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mealType,
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.seedColor,
                        ),
                      ),
                      Text(
                        '${totalCalories.toStringAsFixed(0)} kcal',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.seedColor.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1),
                  ...foods.map((food) => ListTile(
                        title: Text(food.name, style: GoogleFonts.lato(fontWeight: FontWeight.w500)),
                        subtitle: Text('${food.calories.toStringAsFixed(0)} kcal'),
                        dense: true,
                      )),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                        onPressed: () {
                          // TODO: Implement edit functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Función de editar próximamente')),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Ver'),
                        onPressed: () {
                           // TODO: Implement view functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Función de ver próximamente')),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
