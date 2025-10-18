import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/body_measurement_screen.dart';
import 'package:myapp/screens/logs/food_log_screen.dart';
import 'package:myapp/screens/logs/water_log_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget only provides the TabBarView.
    // The Scaffold, AppBar, and TabBar are now handled by MainScreen.
    return const TabBarView(
      children: [
        WaterLogScreen(),
        FoodLogScreen(),
        BodyMeasurementScreen(),
      ],
    );
  }
}
