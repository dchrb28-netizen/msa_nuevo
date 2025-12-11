import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/screens/register_food_screen.dart';
import 'package:myapp/services/achievement_service.dart';

class FoodLogListView extends StatelessWidget {
  final DateTime date;

  const FoodLogListView({super.key, required this.date});

  void _addFoodLog(BuildContext context, Box<FoodLog> box) async {
    final result = await Navigator.push<FoodLog>(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterFoodScreen(),
      ),
    );

    if (result != null) {
      await box.add(result);

      // --- Update Achievements ---
      final achievementService = AchievementService();
      achievementService.grantExperience(10);
      achievementService.updateProgress('first_meal', 1);
      achievementService.updateProgress('cum_meals_500', 1, cumulative: true);
      
      // For cum_foods_50, we need to count distinct food names
      final distinctFoods = box.values.map((log) => log.foodName.toLowerCase()).toSet().length;
      achievementService.updateProgress('cum_foods_50', distinctFoods);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodLogBox = Hive.box<FoodLog>('food_logs');

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: foodLogBox.listenable(),
        builder: (context, Box<FoodLog> box, _) {
          bool isSameDay(DateTime d1, DateTime d2) {
            return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
          }

          final dailyLogs = box.values
              .where((log) => isSameDay(log.date, date))
              .toList();

          if (dailyLogs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No hay comidas registradas para esta fecha.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              24,
              0,
              24,
              80,
            ), // Padding to avoid overlap with FAB
            itemCount: dailyLogs.length,
            itemBuilder: (context, index) {
              final log = dailyLogs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    log.foodName,
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${log.calories.toStringAsFixed(0)} kcal | P: ${log.protein.toStringAsFixed(0)}g, C: ${log.carbohydrates.toStringAsFixed(0)}g, G: ${log.fat.toStringAsFixed(0)}g',
                    style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _confirmDelete(context, box, log),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addFoodLog(context, foodLogBox),
        label: const Text('Añadir Comida'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Box<FoodLog> box, FoodLog log) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar el registro de "${log.foodName}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                box.delete(log.key);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
