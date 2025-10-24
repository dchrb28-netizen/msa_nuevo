import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/menus_screen.dart';
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
    const MenusScreen(),
    const ProgresoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  AppBar? _buildAppBar(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return AppBar(title: const Text('Salud Activa'));
      case 1:
        return AppBar(
          title: const Text('Plan de Comidas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.today), text: 'Hoy'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Semanal'),
            ],
          ),
        );
      case 2:
        return AppBar(
          title: const Text('Progreso'),
        );
      default:
        return AppBar();
    }
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: _widgetOptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget scaffold = Scaffold(
      appBar: _buildAppBar(context),
      drawer: const DrawerMenu(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menús',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Progreso',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To show all labels
      ),
    );

    if (_selectedIndex == 1) { // Adjusted index for MenusScreen
      return DefaultTabController(
        length: 2, // Corresponds to the number of tabs in MenusScreen AppBar
        child: scaffold,
      );
    }

    return scaffold;
  }
}
