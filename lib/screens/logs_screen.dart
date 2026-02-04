import 'package:flutter/material.dart';
import 'package:myapp/screens/food/food_screen.dart';
import 'package:myapp/screens/logs/body_measurement_screen.dart';
import 'package:myapp/screens/water_screen.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        bottom: SubTabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(PhosphorIcons.drop(PhosphorIconsStyle.duotone)),
              text: 'Agua',
            ),
            Tab(
              icon: Icon(PhosphorIcons.hamburger(PhosphorIconsStyle.duotone)),
              text: 'Comida',
            ),
            Tab(
              icon: Icon(PhosphorIcons.ruler(PhosphorIconsStyle.duotone)),
              text: 'Medidas',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          WaterScreen(),
          FoodScreen(),
          BodyMeasurementScreen(),
        ],
      ),
    );
  }
}
