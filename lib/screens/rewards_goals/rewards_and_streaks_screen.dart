import 'package:flutter/material.dart';
import 'package:myapp/screens/achievements/rewards_screen.dart';
import 'package:myapp/screens/rewards_goals/streaks_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RewardsAndStreaksScreen extends StatefulWidget {
  final int initialTabIndex;

  const RewardsAndStreaksScreen({super.key, this.initialTabIndex = 0});

  @override
  State<RewardsAndStreaksScreen> createState() =>
      _RewardsAndStreaksScreenState();
}

class _RewardsAndStreaksScreenState extends State<RewardsAndStreaksScreen> {
  late int _currentIndex;
  final List<Widget> _pages = [
    const RewardsScreen(),
    const StreaksScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Mis Recompensas' : 'Mis Rachas'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.gift()),
            label: 'Recompensas',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.fire()),
            label: 'Rachas',
          ),
        ],
      ),
    );
  }
}
