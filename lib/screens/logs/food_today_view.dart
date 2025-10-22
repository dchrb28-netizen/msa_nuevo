import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/screens/add_food_screen.dart';
import 'package:intl/intl.dart';

class FoodTodayView extends StatefulWidget {
  const FoodTodayView({super.key});

  @override
  State<FoodTodayView> createState() => _FoodTodayViewState();
}

class _FoodTodayViewState extends State<FoodTodayView> {
  DateTime _selectedDate = DateTime.now();

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        final dailyLogs = box.values.where((log) => DateUtils.isSameDay(log.timestamp, _selectedDate)).toList();
        final totalCalories = dailyLogs.fold<double>(0, (sum, log) => sum + ((log.food.calories ?? 0) * log.quantity / 100));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeDate(-1)),
                  Text(DateFormat.yMMMd('es').format(_selectedDate), style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: DateUtils.isSameDay(_selectedDate, DateTime.now()) ? null : () => _changeDate(1)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Total: ${totalCalories.toInt()} kcal', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: dailyLogs.isEmpty
                  ? const Center(child: Text('No hay comidas registradas para esta fecha.'))
                  : ListView.builder(
                      itemCount: dailyLogs.length,
                      itemBuilder: (context, index) {
                        final log = dailyLogs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: _getMealIcon(log.mealType),
                            title: Text(log.food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${log.quantity}g'),
                            trailing: Text('${((log.food.calories ?? 0) * log.quantity / 100).toInt()} kcal'),
                            onLongPress: () => log.delete(),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton.extended(
                onPressed: () => _navigateAndAddFood(context),
                label: const Text('Añadir Comida'),
                icon: const Icon(Icons.add),
                backgroundColor: colorScheme.tertiary,
                foregroundColor: colorScheme.onTertiary,
              ),
            )
          ],
        );
      },
    );
  }

  void _navigateAndAddFood(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddFoodScreen()),
    );

    if (result != null) {
      final food = result['food'] as Food;
      final quantity = result['quantity'] as double;
      final mealType = result['mealType'] as String;

      final log = FoodLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        food: food,
        quantity: quantity,
        mealType: mealType,
        timestamp: _selectedDate,
      );
      Hive.box<FoodLog>('food_logs').add(log);
    }
  }

  Icon _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Desayuno':
        return const Icon(Icons.free_breakfast, color: Colors.orange);
      case 'Almuerzo':
        return const Icon(Icons.lunch_dining, color: Colors.red);
      case 'Cena':
        return const Icon(Icons.dinner_dining, color: Colors.purple);
      case 'Snack':
        return const Icon(Icons.fastfood, color: Colors.blue);
      default:
        return const Icon(Icons.restaurant, color: Colors.grey);
    }
  }
}
