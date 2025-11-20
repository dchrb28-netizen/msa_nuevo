import 'package:flutter/material.dart';
import 'package:myapp/screens/food/food_log_list_view.dart';
import 'package:myapp/screens/food/food_today_screen.dart';
import 'package:myapp/models/food_log.dart';
import 'package:hive/hive.dart';

class FoodScreen extends StatefulWidget {
  // This is no longer a full screen, but the nested tab view for foods.
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addFoodLog(FoodLog log) {
    final foodLogBox = Hive.box<FoodLog>('food_logs');
    foodLogBox.put(log.id, log);
    // Switch to the history tab after adding a log
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    // Returns a Column with the nested TabBar and TabBarView.
    // This widget is then placed inside the main LogsScreen.
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Hoy'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
          ],
          labelColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              FoodTodayScreen(onAddFoodLog: _addFoodLog),
              FoodLogListView(date: DateTime.now()),
            ],
          ),
        ),
      ],
    );
  }
}
