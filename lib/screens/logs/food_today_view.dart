import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/add_food_screen.dart';
import 'package:intl/intl.dart';
import 'package:myapp/widgets/daily_food_log_view.dart';
import 'package:provider/provider.dart';

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
    final userProvider = Provider.of<UserProvider>(context);
    final User? user = userProvider.user;

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
        Expanded(
          child: DailyFoodLogView(
            date: _selectedDate,
            calorieGoal: user?.calorieGoal,
            dietPlan: user?.dietPlan,
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
}
