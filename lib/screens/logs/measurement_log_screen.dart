import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/body_measurement_today_view.dart';
import 'package:myapp/screens/logs/measurement_history_screen.dart';

class MeasurementLogScreen extends StatelessWidget {
  const MeasurementLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medidas Corporales'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Registrar'),
              Tab(text: 'Historial'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BodyMeasurementTodayView(),
            MeasurementHistoryScreen(),
          ],
        ),
      ),
    );
  }
}
