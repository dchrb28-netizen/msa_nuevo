
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/achievements/goals_screen.dart';
import 'package:myapp/screens/achievements/rewards_screen.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/logs_screen.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/recipes/recipes_screen.dart';
import 'package:myapp/screens/settings/about_screen.dart';
import 'package:myapp/screens/settings/edit_profile_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';
import 'package:myapp/screens/training/routines_screen.dart';
import 'package:myapp/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = userProvider.user;

    Color textColorForBackground(Color backgroundColor) {
      return ThemeData.estimateBrightnessForColor(backgroundColor) ==
              Brightness.dark
          ? Colors.white
          : Colors.black;
    }

    final headerTextColor = textColorForBackground(themeProvider.seedColor);

    Widget buildListTile(BuildContext context, {required IconData icon, required Color iconColor, required String title, required Widget destination, int? initialTabIndex}) {
      return ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: GoogleFonts.lato()),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: themeProvider.seedColor,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (user != null && !user.isGuest) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: headerTextColor,
                      backgroundImage: user?.profileImageBytes != null
                          ? MemoryImage(user!.profileImageBytes!)
                          : null,
                      child: user?.profileImageBytes == null
                          ? Icon(Icons.person, size: 40, color: themeProvider.seedColor)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user?.name ?? 'Invitado',
                            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: headerTextColor),
                          ),
                          Text(
                            'Toca para crear o editar tu perfil',
                             style: GoogleFonts.lato(fontSize: 14, color: headerTextColor.withAlpha(204)),
                            softWrap: true,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: themeProvider.seedColor),
            title: Text('Inicio', style: GoogleFonts.lato()),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
            },
          ),
          const Divider(),
          _buildExpansionTile(context, title: 'Registro', icon: Icons.edit, iconColor: Colors.deepPurple, children: [
            buildListTile(context, icon: Icons.water_drop, iconColor: Colors.blue, title: 'Ingesta de Agua', destination: const LogsScreen(initialTabIndex: 0)),
            buildListTile(context, icon: Icons.fastfood, iconColor: Colors.yellow[700]!, title: 'Comidas', destination: const LogsScreen(initialTabIndex: 1)),
            buildListTile(context, icon: Icons.straighten, iconColor: Colors.teal, title: 'Medidas', destination: const LogsScreen(initialTabIndex: 2)),
          ]),
          _buildExpansionTile(context, title: 'Mis Recetas', icon: Icons.menu_book, iconColor: Colors.brown[600]!, children: [
            buildListTile(context, icon: Icons.receipt_long, iconColor: Colors.orange[800]!, title: 'Buscar Recetas', destination: const RecipesScreen(initialTabIndex: 0)),
            buildListTile(context, icon: Icons.favorite, iconColor: Colors.red[400]!, title: 'Recetas Favoritas', destination: const RecipesScreen(initialTabIndex: 1)),
          ]),
          _buildExpansionTile(context, title: 'Entrenamiento', icon: Icons.fitness_center, iconColor: Colors.red[700]!, children: [
            buildListTile(context, icon: Icons.directions_run, iconColor: Colors.blue[700]!, title: 'Ejercicios', destination: const RoutinesScreen()),
            buildListTile(context, icon: Icons.local_library, iconColor: Colors.pink, title: 'Biblioteca', destination: const ExerciseLibraryScreen()),
          ]),
          _buildExpansionTile(context, title: 'Hábitos', icon: Icons.check_circle_outline, iconColor: Colors.lightGreen[800]!, children: [
            buildListTile(context, icon: Icons.notifications, iconColor: Colors.amber[600]!, title: 'Recordatorios', destination: const HabitsScreen(initialTabIndex: 0)),
            buildListTile(context, icon: Icons.hourglass_empty, iconColor: Colors.lime[700]!, title: 'Ayuno Intermitente', destination: const HabitsScreen(initialTabIndex: 1)),
          ]),
          _buildExpansionTile(context, title: 'Logros', icon: Icons.emoji_events, iconColor: Colors.amber[900]!, children: [
            buildListTile(context, icon: Icons.card_giftcard, iconColor: Colors.yellow[600]!, title: 'Recompensas', destination: const RewardsScreen()),
            buildListTile(context, icon: Icons.flag, iconColor: Colors.deepOrange[400]!, title: 'Metas', destination: const GoalsScreen()),
          ]),
          _buildExpansionTile(context, title: 'Configuración', icon: Icons.settings, iconColor: Colors.grey[700]!, children: [
            buildListTile(context, icon: Icons.calculate, iconColor: Colors.green, title: 'Metas Calóricas', destination: const SettingsScreen(initialIndex: 0)),
            buildListTile(context, icon: Icons.monitor_weight, iconColor: Colors.purple, title: 'Objetivos de Peso', destination: const SettingsScreen(initialIndex: 1)),
            buildListTile(context, icon: Icons.palette, iconColor: Colors.orange, title: 'Temas', destination: const SettingsScreen(initialIndex: 2)),
          ]),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.blueGrey[500]!),
            title: Text('Acerca de', style: GoogleFonts.lato()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[800]!),
            title: Text('Cerrar Sesión', style: GoogleFonts.lato()),
            onTap: () {
              userProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  ExpansionTile _buildExpansionTile(BuildContext context, {required String title, required IconData icon, required Color iconColor, required List<Widget> children}) {
    return ExpansionTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
      children: children,
    );
  }
}
