import 'package:flutter/material.dart';
import 'package:myapp/screens/logs/body_measurement_screen.dart';
import 'package:myapp/screens/logs/food_log_screen.dart';
import 'package:myapp/screens/logs/water_log_screen.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LogsScreen extends StatelessWidget {
  final int initialIndex;

  const LogsScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: SubTabBar(
            tabs: [
              Tab(icon: Icon(PhosphorIcons.drop(PhosphorIconsStyle.duotone)), text: 'Agua'),
              Tab(icon: Icon(PhosphorIcons.hamburger(PhosphorIconsStyle.duotone)), text: 'Comida'),
              Tab(icon: Icon(PhosphorIcons.ruler(PhosphorIconsStyle.duotone)), text: 'Medidas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WaterLogScreen(),
            FoodLogScreen(),
            BodyMeasurementScreen(),
          ],
        ),
      ),
    );
  }
}
