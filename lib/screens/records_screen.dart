import 'package:flutter/material.dart';
import 'package:myapp/screens/body_measurement_history_screen.dart';
import 'package:myapp/screens/food_history_screen.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          TabBar(
            tabs: [
              Tab(text: 'Comidas'),
              Tab(text: 'Medidas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                FoodHistoryScreen(),
                BodyMeasurementHistoryScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
