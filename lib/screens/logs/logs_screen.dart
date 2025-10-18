import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/body_measurement_screen.dart';
import 'package:myapp/screens/logs/food_log_screen.dart';
import 'package:myapp/screens/logs/water_log_screen.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_drink), text: 'Agua'),
              Tab(icon: Icon(Icons.fastfood), text: 'Comida'),
              Tab(icon: Icon(Icons.accessibility), text: 'Medidas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WaterLogScreen(),
            FoodLogScreen(),
            BodyMeasurementScreen(),
          ],
        ),
      ),
    );
  }
}
