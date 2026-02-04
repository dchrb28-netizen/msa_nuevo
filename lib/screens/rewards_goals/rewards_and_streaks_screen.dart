import 'package:flutter/material.dart';
import 'package:myapp/screens/achievements_screen.dart';
import 'package:myapp/screens/rewards_goals/streaks_screen.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RewardsAndStreaksScreen extends StatelessWidget {
  final int initialTabIndex;

  const RewardsAndStreaksScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // Se elimina el título
          bottom: SubTabBar(
            tabs: [
              Tab(
                icon: Icon(PhosphorIcons.trophy()),
                text: 'Logros',
              ),
              Tab(
                icon: Icon(PhosphorIcons.fire()),
                text: 'Rachas',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AchievementsScreen(),
            StreaksScreen(),
          ],
        ),
      ),
    );
  }
}
