import 'package:flutter/material.dart';
import 'package:myapp/screens/water_history_screen.dart';
import 'package:myapp/screens/water_today_screen.dart';

class WaterIntakeScreen extends StatelessWidget {
  const WaterIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Hoy'),
              Tab(text: 'Historial'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                WaterTodayScreen(), // The screen with the aquarium
                WaterHistoryScreen(), // The screen with the daily summary list
              ],
            ),
          ),
        ],
      ),
    );
  }
}
