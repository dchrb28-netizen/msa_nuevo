import 'package:flutter/material.dart';
import 'package:myapp/screens/menus/today_menu_screen.dart';
import 'package:myapp/screens/menus/weekly_menu_screen.dart';

class MenusScreen extends StatelessWidget {
  const MenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        TodayMenuScreen(),
        WeeklyMenuScreen(),
      ],
    );
  }
}
