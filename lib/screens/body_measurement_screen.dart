import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/body_measurement_history_view.dart';
import 'package:myapp/screens/logs/body_measurement_today_view.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BodyMeasurementScreen extends StatelessWidget {
  const BodyMeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          SubTabBar(
            tabs: [
              Tab(icon: Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular)), text: 'Hoy'),
              Tab(icon: Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular)), text: 'Historial'),
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
