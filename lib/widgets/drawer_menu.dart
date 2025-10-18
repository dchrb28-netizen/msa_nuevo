import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/achievements/objectives_screen.dart';
import 'package:myapp/screens/achievements/rewards_screen.dart';
import 'package:myapp/screens/habits/intermittent_fasting_screen.dart';
import 'package:myapp/screens/habits/reminders_screen.dart';
import 'package:myapp/screens/logs/activity_log_screen.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/settings/about_screen.dart';
import 'package:myapp/screens/settings/caloric_goals_screen.dart';
import 'package:myapp/screens/settings/theme_settings_screen.dart';
import 'package:myapp/screens/settings/weight_goals_screen.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';
import 'package:myapp/screens/training/exercises_screen.dart';
import 'package:myapp/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = userProvider.user;

    // Function to determine text color based on background brightness
    Color textColorForBackground(Color backgroundColor) {
      return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
          ? Colors.white
          : Colors.black;
    }

    final headerTextColor = textColorForBackground(themeProvider.seedColor);

    Widget buildListTile(BuildContext context, {required IconData icon, required Color iconColor, required String title, required Widget destination}) {
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: headerTextColor,
                      child: Icon(Icons.person, size: 40, color: themeProvider.seedColor),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.name ?? 'Invitado',
                          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: headerTextColor),
                        ),
                        Text(
                          'Toca para editar tu perfil',
                          style: GoogleFonts.lato(fontSize: 14, color: headerTextColor.withAlpha(204)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: themeProvider.seedColor), // Use the exact seed color
            title: Text('Inicio', style: GoogleFonts.lato()),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
            },
          ),
          const Divider(),
          _buildExpansionTile(context,
            title: 'Registro', 
            icon: Icons.edit, 
            iconColor: Colors.purple,
            children: [
              buildListTile(context, icon: Icons.water_drop, iconColor: Colors.blue.shade300, title: 'Ingesta de Agua', destination: const ActivityLogScreen(initialIndex: 0)),
              buildListTile(context, icon: Icons.fastfood, iconColor: Colors.orange.shade300, title: 'Comidas', destination: const ActivityLogScreen(initialIndex: 1)),
              buildListTile(context, icon: Icons.straighten, iconColor: Colors.green.shade300, title: 'Medidas', destination: const ActivityLogScreen(initialIndex: 2)),
            ]
          ),
          _buildExpansionTile(context,
            title: 'Entrenamiento', 
            icon: Icons.fitness_center, 
            iconColor: Colors.orange,
            children: [
              buildListTile(context, icon: Icons.directions_run, iconColor: Colors.orange.shade300, title: 'Ejercicios', destination: const ExercisesScreen()),
              buildListTile(context, icon: Icons.library_books, iconColor: Colors.orange.shade300, title: 'Biblioteca de Ejercicios', destination: const ExerciseLibraryScreen()),
            ]
          ),
          _buildExpansionTile(context,
            title: 'Hábitos', 
            icon: Icons.check_circle_outline, 
            iconColor: Colors.green,
            children: [
              buildListTile(context, icon: Icons.notifications, iconColor: Colors.green.shade300, title: 'Recordatorios', destination: const RemindersScreen()),
              buildListTile(context, icon: Icons.hourglass_empty, iconColor: Colors.green.shade300, title: 'Ayuno Intermitente', destination: const IntermittentFastingScreen()),
            ]
          ),
          _buildExpansionTile(context,
            title: 'Logros', 
            icon: Icons.emoji_events, 
            iconColor: Colors.amber,
            children: [
              buildListTile(context, icon: Icons.card_giftcard, iconColor: Colors.amber.shade300, title: 'Recompensas', destination: const RewardsScreen()),
              buildListTile(context, icon: Icons.flag, iconColor: Colors.amber.shade300, title: 'Objetivos', destination: const ObjectivesScreen()),
            ]
          ),
          const Divider(),
          _buildExpansionTile(context,
            title: 'Configuración', 
            icon: Icons.settings, 
            iconColor: Colors.grey,
            children: [
               buildListTile(context, icon: Icons.pie_chart, iconColor: Colors.blueGrey, title: 'Metas Calóricas', destination: const CaloricGoalsScreen()),
               buildListTile(context, icon: Icons.monitor_weight, iconColor: Colors.blueGrey, title: 'Objetivos de Peso', destination: const WeightGoalsScreen()),
               buildListTile(context, icon: Icons.palette, iconColor: Colors.blueGrey, title: 'Temas', destination: const PantallaTemas()),
            ]
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.lightBlue),
            title: Text('Acerca de', style: GoogleFonts.lato()),
            onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
            ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
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
