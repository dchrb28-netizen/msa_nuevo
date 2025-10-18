import 'package:flutter/material.dart';
import 'package:myapp/screens/body_measurement_history_screen.dart';
import 'package:myapp/screens/food_history_screen.dart';
import 'package:myapp/screens/water_history_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.show_chart), text: 'Medidas'),
                  Tab(icon: Icon(Icons.fastfood_outlined), text: 'Comida'),
                  Tab(icon: Icon(Icons.water_drop_outlined), text: 'Agua'),
                ],
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BodyMeasurementHistoryScreen(),
            FoodHistoryScreen(),
            WaterHistoryScreen(),
          ],
        ),
      ),
    );
  }
}
