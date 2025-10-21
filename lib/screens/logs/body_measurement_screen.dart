import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/logs/body_measurement_history_screen.dart';
import 'package:myapp/screens/logs/body_measurement_today_view.dart';
import 'package:provider/provider.dart';

class BodyMeasurementScreen extends StatelessWidget {
  const BodyMeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tabBackgroundColor = themeProvider.seedColor.withOpacity(isDarkMode ? 0.3 : 0.1);
    final tabLabelColor = Theme.of(context).colorScheme.onSurface;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: tabBackgroundColor,
            child: TabBar(
              indicatorColor: themeProvider.seedColor,
              labelColor: tabLabelColor,
              unselectedLabelColor: tabLabelColor.withOpacity(0.7),
              tabs: const [
                Tab(icon: Icon(Icons.today), text: 'Hoy'),
                Tab(icon: Icon(Icons.history), text: 'Historial'),
              ],
            ),
          ),
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
