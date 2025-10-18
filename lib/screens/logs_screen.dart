import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/logs/water_log_screen.dart';
import 'package:myapp/screens/logs/food_log_screen.dart';
import 'package:myapp/screens/logs/body_measurement_screen.dart';
import 'package:provider/provider.dart';

class LogsScreen extends StatelessWidget {
  final int initialTabIndex;

  const LogsScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    Color textColorForBackground(Color backgroundColor) {
      return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
          ? Colors.white
          : Colors.black;
    }

    final appBarColor = themeProvider.seedColor;
    final tabBarItemColor = textColorForBackground(appBarColor);

    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Registros'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 10),
            child: Theme(
              data: Theme.of(context).copyWith(
                tabBarTheme: TabBarThemeData(
                  labelColor: tabBarItemColor,
                  unselectedLabelColor: tabBarItemColor.withAlpha(178), // Opacidad del 70%
                  indicatorColor: tabBarItemColor,
                ),
              ),
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.water_drop), text: 'Agua'),
                  Tab(icon: Icon(Icons.fastfood), text: 'Comida'),
                  Tab(icon: Icon(Icons.straighten), text: 'Medidas'),
                ],
              ),
            ),
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
