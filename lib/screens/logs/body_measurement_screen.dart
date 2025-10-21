
import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/body_measurement_history_screen.dart';
import 'package:myapp/screens/logs/body_measurement_today_view.dart';

class BodyMeasurementScreen extends StatelessWidget {
  const BodyMeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

    // The DefaultTabController manages the state of the tabs.
    return DefaultTabController(
      length: 2,
      // A Column is used to place the TabBar above the TabBarView.
      child: Column(
        children: [
          // This is the TabBar for 'Hoy' and 'Historial'.
          // It will now correctly inherit the background from the parent screen.
          TabBar(
            indicatorColor: primaryColor,
            labelColor: onSurfaceColor,
            unselectedLabelColor: onSurfaceColor.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Hoy'),
              Tab(text: 'Historial'),
            ],
          ),
          // Expanded ensures that the TabBarView takes up all the remaining screen space.
          const Expanded(
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
