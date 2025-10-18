import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/water_history_screen.dart';
import 'package:myapp/screens/logs/water_today_view.dart';

class WaterLogScreen extends StatelessWidget {
  const WaterLogScreen({super.key});

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
                WaterTodayView(),
                WaterHistoryScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
