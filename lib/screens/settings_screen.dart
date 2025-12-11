import 'package:flutter/material.dart';
import 'package:myapp/screens/settings/caloric_goals_screen.dart';
import 'package:myapp/screens/settings/theme_settings_screen.dart';
import 'package:myapp/screens/settings/weight_goals_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SettingsScreen extends StatefulWidget {
  final int initialIndex;

  const SettingsScreen({super.key, this.initialIndex = 0});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // A key to force the rebuild of the CaloricGoalsScreen
  Key _caloricGoalsKey = UniqueKey();

  void _reloadCaloricGoals() {
    setState(() {
      _caloricGoalsKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(PhosphorIcons.flag(PhosphorIconsStyle.duotone)), text: 'Metas'),
              Tab(icon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.duotone)), text: 'Peso'),
              Tab(icon: Icon(PhosphorIcons.palette(PhosphorIconsStyle.duotone)), text: 'Tema'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CaloricGoalsScreen(key: _caloricGoalsKey), // Use the key here
            WeightGoalsScreen(
              onProfileUpdated: _reloadCaloricGoals,
            ), // Pass the callback
            const ThemeSettingsScreen(),
          ],
        ),
      ),
    );
  }
}
