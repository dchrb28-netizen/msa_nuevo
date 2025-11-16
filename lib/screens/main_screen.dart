import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/menus_screen.dart';
import 'package:myapp/screens/progreso_screen.dart';
import 'package:myapp/screens/training/workout_history_screen.dart'; // Import history screen
import 'package:myapp/screens/training_screen.dart'; // Import training screen
import 'package:myapp/widgets/drawer_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          title: const Text('Entrenamiento'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Historial de Entrenamientos',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkoutHistoryScreen()));
              },
            ),
          ],
        );
      case 2:
        return AppBar(
          title: const Text('Plan de Comidas'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.today), text: 'Hoy'),
              Tab(icon: Icon(Icons.date_range), text: 'Semanal'),
            ],
          ),
        );
      case 3:
        return AppBar(
          title: const Text('Progreso'),
        );
      default:
        return null;
    }
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: <Widget>[
        const DashboardScreen(),
        const TrainingScreen(), // Add the new training screen
        MenusScreen(tabController: _tabController),
        const ProgresoScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Entrenamiento',
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
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
