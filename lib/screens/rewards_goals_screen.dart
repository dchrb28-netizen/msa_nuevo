import 'package:flutter/material.dart';
import 'package:myapp/screens/rewards_goals/rewards_screen.dart';
import 'package:myapp/screens/rewards_goals/streaks_screen.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RewardsGoalsScreen extends StatefulWidget {
  final int initialTabIndex;
  const RewardsGoalsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<RewardsGoalsScreen> createState() => _RewardsGoalsScreenState();
}

class _RewardsGoalsScreenState extends State<RewardsGoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // By leaving the title property null, the back button is still rendered,
        // but no title text is shown.
        bottom: SubTabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(PhosphorIcons.gift()),
              text: 'Recompensas',
            ),
            Tab(
              icon: Icon(PhosphorIcons.fire()),
              text: 'Rachas',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RewardsScreen(),
          StreaksScreen(),
        ],
      ),
    );
  }
}
