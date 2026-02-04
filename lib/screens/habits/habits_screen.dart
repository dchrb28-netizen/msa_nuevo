import 'package:flutter/material.dart';
import 'package:myapp/screens/habits/daily_tasks_screen.dart';
import 'package:myapp/screens/habits/intermittent_fasting_screen.dart';
import 'package:myapp/screens/habits/reminders_screen.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';

// Revertimos a un StatelessWidget porque ya no necesitamos gestionar el estado del TabController aquí.
class HabitsScreen extends StatelessWidget {
  final int initialTabIndex;
  const HabitsScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 3, // Aumentado a 3 pestañas
      child: Scaffold(
        appBar: AppBar(
          // El título se ha eliminado para un look más limpio, la pestaña activa ya da contexto.
          title: null,
          // Los actions se han movido a un FAB en la pantalla de recordatorios.
          actions: const [],
          bottom: const SubTabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.notifications_outlined),
                text: 'Recordatorios',
              ),
              Tab(icon: Icon(Icons.task_alt_outlined), text: 'Tareas'),
              Tab(icon: Icon(Icons.hourglass_empty_outlined), text: 'Ayuno'),
            ],
          ),
        ),
        // El TabBarView ahora contiene la RemindersScreen con su propio Scaffold y FAB.
        body: const TabBarView(
          children: [RemindersScreen(), DailyTasksScreen(), IntermittentFastingScreen()],
        ),
      ),
    );
  }
}
