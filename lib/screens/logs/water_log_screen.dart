import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/water_history_screen.dart';
import 'package:myapp/screens/logs/water_today_view.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';

class WaterLogScreen extends StatelessWidget {
  const WaterLogScreen({super.key});

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
              children: [WaterTodayView(), WaterHistoryScreen()],
            ),
          ),
        ],
      ),
    );
  }
}
