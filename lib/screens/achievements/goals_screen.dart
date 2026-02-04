import 'package:flutter/material.dart';
import 'package:myapp/screens/settings/caloric_goals_screen.dart';
import 'package:myapp/screens/achievements/objectives_screen.dart';
import 'package:myapp/screens/settings/theme_settings_screen.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const SubTabBar(
            tabs: [
              Tab(icon: Icon(Icons.flag_outlined), text: 'Objetivos'),
              Tab(
                icon: Icon(Icons.local_fire_department_outlined),
                text: 'Metas Calóricas',
              ),
              Tab(icon: Icon(Icons.color_lens_outlined), text: 'Tema'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ObjectivesScreen(),
            CaloricGoalsScreen(),
            ThemeSettingsScreen(),
          ],
        ),
      ),
    );
  }
}
