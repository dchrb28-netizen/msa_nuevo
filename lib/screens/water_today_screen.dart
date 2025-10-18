import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/water_history_screen.dart';
import 'package:myapp/screens/logs/water_today_view.dart';

class WaterTodayScreen extends StatefulWidget {
  const WaterTodayScreen({super.key});

  @override
  State<WaterTodayScreen> createState() => _WaterTodayScreenState();
}

class _WaterTodayScreenState extends State<WaterTodayScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Hoy'),
          Tab(text: 'Historial'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          WaterTodayView(),
          WaterHistoryScreen(),
        ],
      ),
    );
  }
}
