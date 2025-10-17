import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/logs/activity_log_screen.dart';
import 'package:myapp/screens/progreso_screen.dart';
import 'package:myapp/widgets/drawer_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const ActivityLogScreen(),
    const ProgresoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String lunaImagePath = isDarkMode
        ? 'assets/luna_png/luna_inicio_b.png'
        : 'assets/luna_png/luna_inicio_w.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTrack AI'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      drawer: const DrawerMenu(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                lunaImagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Menús',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Progreso',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withAlpha(153),
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface.withAlpha(204),
        elevation: 0,
      ),
    );
  }
}
