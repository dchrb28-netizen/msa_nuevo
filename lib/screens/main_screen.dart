import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/menus_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/progreso_screen.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/widgets/achievement_snackbar_listener.dart';
import 'package:myapp/widgets/drawer_menu.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

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
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String getFrameForTitle(String? title) {
    if (title == null) return 'assets/marcos/marco_bienvenido.png';
    return 'assets/marcos/marco_${title.toLowerCase().replaceAll(' ', '_')}.png';
  }

  @override
  Widget build(BuildContext context) {
    return AchievementSnackbarListener(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MSA'),
          elevation: 0,
        ),
        drawer: const DrawerMenu(),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Consumer2<UserProvider, AchievementService>(
          builder: (context, userProvider, achievementService, child) {
            final user = userProvider.user;
            final selectedTitle = achievementService.userProfile.selectedTitle;
            final frameAsset = getFrameForTitle(selectedTitle);
            final imageProvider = user?.profileImageBytes != null
                ? MemoryImage(user!.profileImageBytes!)
                : null;

            return BottomNavigationBar(
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
                BottomNavigationBarItem(
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (user?.showProfileFrame ?? true)
                        Image.asset(
                          frameAsset,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: imageProvider as ImageProvider?,
                        child: imageProvider == null
                            ? const Icon(Icons.person, size: 15)
                            : null,
                      ),
                    ],
                  ),
                  label: 'Perfil',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            );
          },
        ),
      ),
    );
  }
}
