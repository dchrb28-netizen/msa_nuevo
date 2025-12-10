import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/menus_screen.dart';
import 'package:myapp/screens/progreso_screen.dart';
import 'package:myapp/widgets/drawer_menu.dart';
import 'package:myapp/widgets/achievement_snackbar_listener.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    MenusScreen(),
    ProgresoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AchievementSnackbarListener(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        drawer: const DrawerMenu(), // The profile can be accessed from the drawer
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.house(PhosphorIconsStyle.duotone)),
              activeIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.notebook(PhosphorIconsStyle.duotone)),
              activeIcon: Icon(PhosphorIcons.notebook(PhosphorIconsStyle.fill)),
              label: 'Menus',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.chartLineUp(PhosphorIconsStyle.duotone)),
              activeIcon: Icon(PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill)),
              label: 'Progreso',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
