import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/body_measurement_today_view.dart';
import 'package:myapp/screens/logs/measurement_history_screen.dart';

class BodyMeasurementScreen extends StatefulWidget {
  const BodyMeasurementScreen({super.key});

  @override
  State<BodyMeasurementScreen> createState() => _BodyMeasurementScreenState();
}

class _BodyMeasurementScreenState extends State<BodyMeasurementScreen> with SingleTickerProviderStateMixin {
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
          BodyMeasurementTodayView(),
          MeasurementHistoryScreen(),
        ],
      ),
    );
  }
}
