import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/body_measurement_history_screen.dart';
import 'package:myapp/screens/logs/body_measurement_today_view.dart';

class BodyMeasurementScreen extends StatelessWidget {
  const BodyMeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Hoy'),
              Tab(text: 'Historial'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                BodyMeasurementTodayView(),
                BodyMeasurementHistoryScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
