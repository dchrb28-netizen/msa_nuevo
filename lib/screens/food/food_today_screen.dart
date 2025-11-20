import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/screens/food/food_log_screen.dart';
import 'package:myapp/widgets/food/calorie_summary_card.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/user_provider.dart';

class FoodTodayScreen extends StatelessWidget {
  final Function(FoodLog) onAddFoodLog;

  const FoodTodayScreen({super.key, required this.onAddFoodLog});

  void _navigateToLogScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodLogScreen(onAddFoodLog: onAddFoodLog),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      body: ValueListenableBuilder<Box<FoodLog>>(
        valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
        builder: (context, box, _) {
          final todayLogs = box.values.where((log) {
            final now = DateTime.now();
            return log.date.year == now.year &&
                log.date.month == now.month &&
                log.date.day == now.day;
          }).toList();

          double caloriesConsumed = 0;
          double proteinConsumed = 0;
          double carbsConsumed = 0;
          double fatsConsumed = 0;

          for (var log in todayLogs) {
            caloriesConsumed += log.calories;
            proteinConsumed += log.protein;
            carbsConsumed += log.carbohydrates;
            fatsConsumed += log.fat;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  if (user != null)
                    CalorieSummaryCard(
                      caloriesGoal: user.calorieGoal ?? 0.0,
                      caloriesConsumed: caloriesConsumed,
                      proteinGoal: user.proteinGoal ?? 0.0,
                      proteinConsumed: proteinConsumed,
                      carbsGoal: user.carbGoal ?? 0.0,
                      carbsConsumed: carbsConsumed,
                      fatsGoal: user.fatGoal ?? 0.0,
                      fatsConsumed: fatsConsumed,
                    )
                  else
                    const Center(child: Text('Cargando datos del usuario...')),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToLogScreen(context),
                    icon: const Icon(Icons.add_box_rounded, size: 28),
                    label: const Text('Registrar Comida'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
