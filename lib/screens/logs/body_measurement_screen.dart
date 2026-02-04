import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/body_measurement_history_view.dart';
import 'package:myapp/screens/logs/body_measurement_today_view.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';

class BodyMeasurementScreen extends StatelessWidget {
  const BodyMeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SubTabBar(
            tabs: [
              Tab(icon: Icon(Icons.today), text: 'Hoy'),
              Tab(icon: Icon(Icons.history), text: 'Historial'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                BodyMeasurementTodayView(),
                BodyMeasurementHistoryView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
