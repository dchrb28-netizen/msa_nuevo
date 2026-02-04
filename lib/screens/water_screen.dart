import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/water_history_screen.dart';
import 'package:myapp/screens/logs/water_today_view.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          SubTabBar(
            tabs: [
              Tab(
                icon: Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular)),
                text: 'Hoy',
              ),
              Tab(
                icon: Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular)),
                text: 'Historial',
              ),
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
