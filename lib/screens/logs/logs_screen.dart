import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/logs/body_measurement_screen.dart';
import 'package:myapp/screens/logs/food_log_screen.dart';
import 'package:myapp/screens/logs/water_log_screen.dart';
import 'package:provider/provider.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? themeProvider.seedColor;
    final tabColor = ThemeData.estimateBrightnessForColor(appBarColor) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            indicatorColor: tabColor,
            labelColor: tabColor,
            unselectedLabelColor: tabColor.withAlpha((255 * 0.7).round()),
            tabs: const [
              Tab(icon: Icon(Icons.local_drink), text: 'Agua'),
              Tab(icon: Icon(Icons.fastfood), text: 'Comida'),
              Tab(icon: Icon(Icons.accessibility), text: 'Medidas'),
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
