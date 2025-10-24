import 'package:flutter/material.dart';
import 'package:myapp/screens/menus/today_menu_screen.dart';
import 'package:myapp/screens/menus/weekly_planner_screen.dart';
import 'package:myapp/widgets/ui/watermark_image.dart';

class MenusScreen extends StatelessWidget {
  final TabController tabController;

  const MenusScreen({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const WatermarkImage(imageName: 'comida'),
        TabBarView(
          controller: tabController,
          children: const [
            TodayMenuScreen(),
            WeeklyPlannerScreen(),
          ],
        ),
      ],
    );
  }
}
