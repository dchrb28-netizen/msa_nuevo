import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/menus_screen.dart';
import 'package:myapp/screens/training/training_screen.dart';
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
    const TrainingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return AppBar(title: const Text('Salud Activa'));
      case 1:
        return AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.today), text: 'Hoy'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Semanal'),
            ],
          ),
        );
      case 2:
        return AppBar(
          // Se elimina el título para dar más espacio a las pestañas
          // title: const Text('Entrenamiento'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.fitness_center), text: 'Mi Rutina'),
              Tab(icon: Icon(Icons.library_books), text: 'Biblioteca'),
            ],
          ),
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
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Entrenamiento',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );

    if (_selectedIndex == 1 || _selectedIndex == 2) {
      return DefaultTabController(
        length: 2,
        child: scaffold,
      );
    }

    return scaffold;
  }
}
