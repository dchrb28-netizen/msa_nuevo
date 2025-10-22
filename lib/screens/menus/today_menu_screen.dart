import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class TodayMenuScreen extends StatelessWidget {
  const TodayMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Use the Consumer to get data from MealPlanProvider
    return Consumer<MealPlanProvider>(
      builder: (context, mealPlanProvider, child) {
        // Get the meal plan for the current day from the provider
        final dailyMenu = mealPlanProvider.getPlanForDay(DateTime.now());

        // Filter out meal types that have no planned foods
        final activeMealTypes = dailyMenu.keys.where((mealType) => dailyMenu[mealType]!.isNotEmpty).toList();

        if (activeMealTypes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No hay comidas planificadas para hoy',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ve al Planificador Semanal para añadir comidas a tu plan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: activeMealTypes.length,
          itemBuilder: (context, index) {
            final mealType = activeMealTypes[index];
            final foods = dailyMenu[mealType]!;
            final totalCalories = foods.fold(0.0, (sum, food) => sum + (food.calories ?? 0));

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
                          subtitle: Text('${(food.calories ?? 0).toStringAsFixed(0)} kcal'),
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
                            // TODO: Implement edit functionality by navigating to EditMealScreen
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
                             // TODO: Implement view functionality by navigating to MealDetailScreen
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
        );
      },
    );
  }
}
