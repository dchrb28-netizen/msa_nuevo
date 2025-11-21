import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/logs/food_history_screen.dart';
import 'package:myapp/screens/logs/food_today_view.dart';
import 'package:provider/provider.dart';
import 'package:myapp/screens/menus/edit_meal_screen.dart';
import 'package:intl/intl.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  final DateTime _selectedDate = DateTime.now();

  void _selectMealTypeAndEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final mealTypes = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks'];
        final mealIcons = [
          Icons.free_breakfast,
          Icons.lunch_dining,
          Icons.dinner_dining,
          Icons.fastfood,
        ];

        return Wrap(
          children: List.generate(mealTypes.length, (index) {
            return ListTile(
              leading: Icon(mealIcons[index]),
              title: Text(mealTypes[index]),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMealScreen(
                      mealType: mealTypes[index],
                      date: _selectedDate,
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final tabBackgroundColor = themeProvider.seedColor.withAlpha(
      Theme.of(context).brightness == Brightness.dark ? 77 : 26,
    );
    final tabLabelColor = Theme.of(context).colorScheme.onSurface;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: tabBackgroundColor,
            child: TabBar(
              indicatorColor: themeProvider.seedColor,
              labelColor: tabLabelColor,
              unselectedLabelColor: tabLabelColor.withAlpha(
                (255 * 0.7).round(),
              ),
              tabs: const [
                Tab(icon: Icon(Icons.today), text: 'Hoy'),
                Tab(icon: Icon(Icons.history), text: 'Historial'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [FoodTodayView(), FoodHistoryScreen()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _selectMealTypeAndEdit(context),
          label: const Text('Registrar'),
          icon: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
