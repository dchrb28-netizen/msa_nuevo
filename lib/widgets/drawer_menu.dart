import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/logs/logs_screen.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/recipes/recipes_screen.dart';
import 'package:myapp/screens/rewards_goals/rewards_and_streaks_screen.dart';
import 'package:myapp/screens/settings/about_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/screens/training/training_screen.dart';
import 'package:myapp/screens/backup_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  Color textColorForBackground(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  String getFrameForTitle(String? title) {
    if (title == null) return 'assets/marcos/marco_bienvenido.png';
    return 'assets/marcos/marco_${title.toLowerCase().replaceAll(' ', '_')}.png';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    Widget buildLogListTile(
      BuildContext context, {
      required IconData icon,
      required Color iconColor,
      required String title,
      required int tabIndex,
    }) {
      return ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: GoogleFonts.lato()),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogsScreen(initialIndex: tabIndex),
            ),
          );
        },
      );
    }

    Widget buildListTile(
      BuildContext context, {
      required IconData icon,
      required Color iconColor,
      required String title,
      required Widget destination,
    }) {
      return ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: GoogleFonts.lato()),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Consumer2<UserProvider, AchievementService>(
            builder: (context, userProvider, achievementService, child) {
              final user = userProvider.user;
              final selectedTitle = achievementService.userProfile.selectedTitle;
              final frameAsset = getFrameForTitle(selectedTitle);
              final headerTextColor = textColorForBackground(themeProvider.seedColor);

              return DrawerHeader(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(color: themeProvider.seedColor),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (user?.showProfileFrame ?? true)
                              ClipOval(
                                child: Image.asset(
                                  frameAsset,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: headerTextColor,
                              backgroundImage: user?.profileImageBytes != null
                                  ? MemoryImage(user!.profileImageBytes!)
                                  : null,
                              child: user?.profileImageBytes == null
                                  ? Icon(
                                      PhosphorIcons.person(),
                                      size: 30,
                                      color: themeProvider.seedColor,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user?.name ?? 'Invitado',
                                style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: headerTextColor,
                                ),
                              ),
                              Text(
                                'Toca para ver o editar tu perfil',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: headerTextColor.withAlpha(204),
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(PhosphorIcons.house(), color: themeProvider.seedColor),
            title: Text('Inicio', style: GoogleFonts.lato()),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
          ),
          const Divider(),
          _buildExpansionTile(
            context,
            title: 'Registro',
            icon: PhosphorIcons.notebook(),
            iconColor: Colors.deepPurple,
            children: [
              buildLogListTile(
                context,
                icon: PhosphorIcons.drop(),
                iconColor: Colors.blue,
                title: 'Ingesta de Agua',
                tabIndex: 0,
              ),
              buildLogListTile(
                context,
                icon: PhosphorIcons.hamburger(),
                iconColor: Colors.yellow[700]!,
                title: 'Comidas',
                tabIndex: 1,
              ),
              buildLogListTile(
                context,
                icon: PhosphorIcons.ruler(),
                iconColor: Colors.teal,
                title: 'Medidas',
                tabIndex: 2,
              ),
            ],
          ),
          _buildExpansionTile(
            context,
            title: 'Mis Recetas',
            icon: PhosphorIcons.bookOpen(),
            iconColor: Colors.brown[600]!,
            children: [
              buildListTile(
                context,
                icon: PhosphorIcons.magnifyingGlass(),
                iconColor: Colors.orange[800]!,
                title: 'Buscar Recetas',
                destination: const RecipesScreen(initialTabIndex: 0),
              ),
              buildListTile(
                context,
                icon: PhosphorIcons.heart(),
                iconColor: Colors.red[400]!,
                title: 'Recetas Favoritas',
                destination: const RecipesScreen(initialTabIndex: 1),
              ),
            ],
          ),
          _buildExpansionTile(
            context,
            title: 'Entrenamiento',
            icon: PhosphorIcons.barbell(),
            iconColor: Colors.red[700]!,
            children: [
              buildListTile(
                context,
                icon: PhosphorIcons.listChecks(),
                iconColor: Colors.blue[700]!,
                title: 'Rutinas',
                destination: const TrainingScreen(initialTabIndex: 0),
              ),
              buildListTile(
                context,
                icon: PhosphorIcons.books(),
                iconColor: Colors.pink,
                title: 'Biblioteca',
                destination: const TrainingScreen(initialTabIndex: 1),
              ),
            ],
          ),
          _buildExpansionTile(
            context,
            title: 'Hábitos',
            icon: PhosphorIcons.checkCircle(),
            iconColor: Colors.lightGreen[800]!,
            children: [
              buildListTile(
                context,
                icon: PhosphorIcons.bell(),
                iconColor: Colors.amber[600]!,
                title: 'Recordatorios',
                destination: const HabitsScreen(initialTabIndex: 0),
              ),
              buildListTile(
                context,
                icon: PhosphorIcons.hourglass(),
                iconColor: Colors.lime[700]!,
                title: 'Ayuno Intermitente',
                destination: const HabitsScreen(initialTabIndex: 1),
              ),
            ],
          ),
          _buildExpansionTile(
            context,
            title: 'Hitos',
            icon: PhosphorIcons.trophy(),
            iconColor: Colors.amber[900]!,
            children: [
              buildListTile(
                context,
                icon: PhosphorIcons.medal(),
                iconColor: Colors.yellow[600]!,
                title: 'Mis Logros',
                destination: const RewardsAndStreaksScreen(initialTabIndex: 0),
              ),
              buildListTile(
                context,
                icon: PhosphorIcons.fire(),
                iconColor: Colors.deepOrange[400]!,
                title: 'Rachas',
                destination: const RewardsAndStreaksScreen(initialTabIndex: 1),
              ),
            ],
          ),
          _buildExpansionTile(
            context,
            title: 'Configuración',
            icon: PhosphorIcons.gear(),
            iconColor: Colors.grey[700]!,
            children: [
              buildListTile(
                context,
                icon: PhosphorIcons.calculator(),
                iconColor: Colors.green,
                title: 'Metas Calóricas',
                destination: const SettingsScreen(initialIndex: 0),
              ),
              buildListTile(
                context,
                icon: PhosphorIcons.heartbeat(),
                iconColor: Colors.purple,
                title: 'Objetivos de Peso',
                destination: const SettingsScreen(initialIndex: 1),
              ),
              buildListTile(
                context,
                icon: PhosphorIcons.palette(),
                iconColor: Colors.orange,
                title: 'Temas',
                destination: const SettingsScreen(initialIndex: 2),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: Icon(PhosphorIcons.info(), color: Colors.blueGrey[500]!),
            title: Text('Acerca de', style: GoogleFonts.lato()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              PhosphorIcons.cloudArrowUp(),
              color: Colors.blue[800]!,
            ),
            title: Text('Respaldo', style: GoogleFonts.lato()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackupScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  ExpansionTile _buildExpansionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
      children: children,
    );
  }
}
