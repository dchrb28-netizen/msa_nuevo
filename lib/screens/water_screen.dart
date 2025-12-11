import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/logs/water_history_screen.dart';
import 'package:myapp/screens/logs/water_today_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final tabBackgroundColor = themeProvider.seedColor.withAlpha(
      Theme.of(context).brightness == Brightness.dark ? 77 : 26,
    );
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
              unselectedLabelColor: tabLabelColor.withAlpha(
                (255 * 0.7).round(),
              ),
              tabs: [
                Tab(icon: Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular)), text: 'Hoy'),
                Tab(icon: Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular)), text: 'Historial'),
              ],
            ),
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
