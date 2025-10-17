import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/food_intake_screen.dart';
import 'package:myapp/screens/logs/measurement_log_screen.dart';
import 'package:myapp/screens/water_today_screen.dart';

class ActivityLogScreen extends StatefulWidget {
  final int initialIndex;

  const ActivityLogScreen({super.key, this.initialIndex = 0});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Registros', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.water_drop_outlined), text: 'Agua'),
            Tab(icon: Icon(Icons.restaurant_menu_outlined), text: 'Comida'),
            Tab(icon: Icon(Icons.square_foot_outlined), text: 'Medidas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          WaterTodayScreen(),
          FoodIntakeScreen(),
          MeasurementLogScreen(),
        ],
      ),
    );
  }
}
