import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/logs/food_history_screen.dart';
import 'package:myapp/screens/logs/food_today_view.dart';
import 'package:provider/provider.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final tabBackgroundColor = themeProvider.seedColor.withAlpha(
      Theme.of(context).brightness == Brightness.dark ? 77 : 26,
    );
    final tabLabelColor = Theme.of(context).colorScheme.onSurface;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: tabBackgroundColor,
            child: TabBar(
              indicatorColor: themeProvider.seedColor,
              labelColor: tabLabelColor,
              unselectedLabelColor: tabLabelColor.withAlpha(
                (255 * 0.7).round(),
              ),
              tabs: const [
                Tab(icon: Icon(Icons.today), text: 'Hoy'),
                Tab(icon: Icon(Icons.history), text: 'Historial'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [FoodTodayView(), FoodHistoryScreen()],
        ),
      ),
    );
  }
}
