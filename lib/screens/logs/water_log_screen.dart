import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/water_history_screen.dart';
import 'package:myapp/screens/logs/water_today_view.dart';

class WaterLogScreen extends StatelessWidget {
  const WaterLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: primaryColor,
            labelColor: onSurfaceColor,
            unselectedLabelColor: onSurfaceColor.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Hoy'),
              Tab(text: 'Historial'),
            ],
          ),
          const Expanded(
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
