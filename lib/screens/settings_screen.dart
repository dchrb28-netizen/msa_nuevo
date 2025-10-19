import 'package:flutter/material.dart';
import 'package:myapp/screens/settings/caloric_goals_screen.dart';
import 'package:myapp/screens/settings/theme_settings_screen.dart';
import 'package:myapp/screens/settings/weight_goals_screen.dart';

class SettingsScreen extends StatelessWidget {
  final int initialIndex;

  const SettingsScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.flag), text: 'Metas'),
              Tab(icon: Icon(Icons.monitor_weight), text: 'Peso'),
              Tab(icon: Icon(Icons.palette), text: 'Tema'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CaloricGoalsScreen(),
            WeightGoalsScreen(),
            ThemeSettingsScreen(),
          ],
        ),
      ),
    );
  }
}
