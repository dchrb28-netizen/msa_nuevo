import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/food/food_screen.dart'; // Import the new nested tab screen
import 'package:myapp/screens/logs/body_measurement_screen.dart';
import 'package:myapp/screens/logs/water_log_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class LogsScreen extends StatelessWidget {
  final int initialTabIndex;

  const LogsScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final appBarColor = themeProvider.seedColor;
    final tabBarItemColor =
        ThemeData.estimateBrightnessForColor(appBarColor) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          foregroundColor: tabBarItemColor,
          bottom: TabBar(
            indicatorColor: tabBarItemColor,
            labelColor: tabBarItemColor,
            unselectedLabelColor: tabBarItemColor.withAlpha(
              178,
            ), // Fixed: Used withAlpha instead of withOpacity
            tabs: [
              Tab(icon: Icon(PhosphorIcons.drop(PhosphorIconsStyle.regular)), text: 'Agua'),
              Tab(icon: Icon(PhosphorIcons.bowlFood(PhosphorIconsStyle.regular)), text: 'Comida'),
              Tab(icon: Icon(PhosphorIcons.ruler(PhosphorIconsStyle.regular)), text: 'Medidas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WaterLogScreen(),
            FoodScreen(), // <-- Here is the new integrated screen!
            BodyMeasurementScreen(),
          ],
        ),
      ),
    );
  }
}
