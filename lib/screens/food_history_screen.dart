import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/food_log.dart';

class FoodHistoryScreen extends StatelessWidget {
  const FoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<FoodLog> foodLogBox = Hive.box<FoodLog>('food_logs');

    return ValueListenableBuilder(
      valueListenable: foodLogBox.listenable(),
      builder: (context, Box<FoodLog> box, _) {
        final allFoodLogs = box.values.toList();

        return ListView.builder(
          itemCount: allFoodLogs.length,
          itemBuilder: (context, index) {
            final foodLog = allFoodLogs[index];
            final food = foodLog.food;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(food.name, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                subtitle: Text('${food.calories} kcal - ${DateFormat.yMMMd('es').format(foodLog.timestamp)}', style: GoogleFonts.lato()),
                trailing: Text(foodLog.mealType, style: GoogleFonts.lato(fontStyle: FontStyle.italic)),
              ),
            );
          },
        );
      },
    );
  }
}
