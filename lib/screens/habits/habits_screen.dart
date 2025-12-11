import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/habits/intermittent_fasting_screen.dart';
import 'package:myapp/screens/habits/reminders_screen.dart';
import 'package:provider/provider.dart';

// Revertimos a un StatelessWidget porque ya no necesitamos gestionar el estado del TabController aquí.
class HabitsScreen extends StatelessWidget {
  final int initialTabIndex;
  const HabitsScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ??
        themeProvider.seedColor;
    final isDark =
        ThemeData.estimateBrightnessForColor(appBarColor) == Brightness.dark;
    final tabColor = isDark ? Colors.white : Colors.black;

    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 2, // Reverted to 2
      child: Scaffold(
        appBar: AppBar(
          // El título se ha eliminado para un look más limpio, la pestaña activa ya da contexto.
          title: null,
          // Los actions se han movido a un FAB en la pantalla de recordatorios.
          actions: const [],
          bottom: TabBar(
            indicatorColor: tabColor,
            labelColor: tabColor,
            unselectedLabelColor: tabColor.withAlpha(180),
            tabs: const [
              Tab(
                icon: Icon(Icons.notifications_outlined),
                text: 'Recordatorios',
              ),
              Tab(icon: Icon(Icons.hourglass_empty_outlined), text: 'Ayuno'),
            ],
          ),
        ),
        // El TabBarView ahora contiene la RemindersScreen con su propio Scaffold y FAB.
        body: const TabBarView(
          children: [RemindersScreen(), IntermittentFastingScreen()],
        ),
      ),
    );
  }
}
