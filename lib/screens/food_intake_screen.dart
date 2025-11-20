import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/food_history_screen.dart';
import 'package:myapp/screens/logs/food_today_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FoodIntakeScreen extends StatefulWidget {
  const FoodIntakeScreen({super.key});

  @override
  State<FoodIntakeScreen> createState() => _FoodIntakeScreenState();
}

class _FoodIntakeScreenState extends State<FoodIntakeScreen>
    with SingleTickerProviderStateMixin {
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
        tabs: [
          Tab(icon: Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular)), text: 'Hoy'),
          Tab(icon: Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular)), text: 'Historial'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [FoodTodayView(), FoodHistoryScreen()],
      ),
    );
  }
}
