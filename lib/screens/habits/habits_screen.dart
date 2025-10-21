
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/habits/intermittent_fasting_screen.dart';
import 'package:myapp/screens/habits/reminders_screen.dart';
import 'package:provider/provider.dart';

class HabitsScreen extends StatelessWidget {
  final int initialTabIndex;
  const HabitsScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine text/icon color based on AppBar's background
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? themeProvider.seedColor;
    final tabColor = ThemeData.estimateBrightnessForColor(appBarColor) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // Remove the title to have a cleaner look
          title: null,
          bottom: TabBar(
            indicatorColor: tabColor, // Use a contrasting color for the indicator
            labelColor: tabColor, // Use a contrasting color for the selected tab
            unselectedLabelColor: tabColor.withOpacity(0.7), // Slightly faded for unselected tabs
            tabs: const [
              Tab(icon: Icon(Icons.notifications), text: 'Recordatorios'),
              Tab(icon: Icon(Icons.hourglass_empty), text: 'Ayuno'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RemindersScreen(),
            IntermittentFastingScreen(),
          ],
        ),
      ),
    );
  }
}
