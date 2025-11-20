import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/history_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/training_screen.dart';
import 'package:myapp/widgets/drawer_menu.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/user_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Se elimina la lista de widgets estática para que se reconstruyan

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // El widget del dashboard ahora se construye aquí, dentro del Consumer.
    final List<Widget> screens = [
      Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Se reconstruye el DashboardScreen cuando UserProvider notifica cambios.
          return const DashboardScreen();
        },
      ),
      const TrainingScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MSA'),
        elevation: 0,
      ),
      drawer: const DrawerMenu(),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Entrenar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Asegura que todos los ítems sean visibles
      ),
    );
  }
}
