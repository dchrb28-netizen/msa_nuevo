import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/food_history_screen.dart';
import 'package:myapp/screens/logs/food_today_view.dart';

class FoodLogScreen extends StatelessWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          TabBar(
            tabs: [
              Tab(text: 'Hoy'),
              Tab(text: 'Historial'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                FoodTodayView(),
                FoodHistoryScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
