import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:provider/provider.dart';

// New screen imports
import 'package:myapp/screens/achievements/objectives_screen.dart';
import 'package:myapp/screens/achievements/rewards_screen.dart';
import 'package:myapp/screens/habits/intermittent_fasting_screen.dart';
import 'package:myapp/screens/habits/reminders_screen.dart';
import 'package:myapp/screens/logs/food_log_screen.dart';
import 'package:myapp/screens/logs/measurement_log_screen.dart';
import 'package:myapp/screens/logs/water_log_screen.dart';
import 'package:myapp/screens/settings/caloric_goals_screen.dart';
import 'package:myapp/screens/settings/theme_settings_screen.dart';
import 'package:myapp/screens/settings/weight_goals_screen.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';
import 'package:myapp/screens/training/exercises_screen.dart';

// Existing imports
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/welcome_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    // Helper for list tiles
    Widget buildListTile(BuildContext context, {required IconData icon, required Color iconColor, required String title, required Widget destination}) {
      return ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: GoogleFonts.lato()),
        onTap: () {
          Navigator.pop(context); // Close the drawer
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Builder(
            builder: (BuildContext builderContext) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(builderContext);
                  Navigator.push(builderContext, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                },
                child: UserAccountsDrawerHeader(
                  accountName: Text(
                    user?.name ?? 'Usuario',
                    style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(
                    'Toca para editar tu perfil',
                    style: GoogleFonts.lato(fontSize: 14),
                  ),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    // A colorful placeholder for the user
                    child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
                  ),
                  decoration: const BoxDecoration(
                    // Use a gradient for a more modern look
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: Text('Inicio', style: GoogleFonts.lato()),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
            },
          ),
          const Divider(),

          // Registro Section
          ExpansionTile(
            leading: const Icon(Icons.edit, color: Colors.purple),
            title: Text('Registro', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            children: <Widget>[
              buildListTile(context, icon: Icons.water_drop, iconColor: Colors.purple.shade300, title: 'Ingesta de Agua', destination: const WaterLogScreen()),
              buildListTile(context, icon: Icons.fastfood, iconColor: Colors.purple.shade300, title: 'Comidas', destination: const FoodLogScreen()),
              buildListTile(context, icon: Icons.straighten, iconColor: Colors.purple.shade300, title: 'Medidas', destination: const MeasurementLogScreen()),
            ],
          ),

          // Entrenamiento Section
          ExpansionTile(
            leading: const Icon(Icons.fitness_center, color: Colors.orange),
            title: Text('Entrenamiento', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            children: <Widget>[
              buildListTile(context, icon: Icons.directions_run, iconColor: Colors.orange.shade300, title: 'Ejercicios', destination: const ExercisesScreen()),
              buildListTile(context, icon: Icons.library_books, iconColor: Colors.orange.shade300, title: 'Biblioteca de Ejercicios', destination: const ExerciseLibraryScreen()),
            ],
          ),

          // Hábitos Section
          ExpansionTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.green),
            title: Text('Hábitos', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            children: <Widget>[
              buildListTile(context, icon: Icons.notifications, iconColor: Colors.green.shade300, title: 'Recordatorios', destination: const RemindersScreen()),
              buildListTile(context, icon: Icons.hourglass_empty, iconColor: Colors.green.shade300, title: 'Ayuno Intermitente', destination: const IntermittentFastingScreen()),
            ],
          ),

          // Logros Section
          ExpansionTile(
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            title: Text('Logros', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            children: <Widget>[
              buildListTile(context, icon: Icons.card_giftcard, iconColor: Colors.amber.shade300, title: 'Recompensas', destination: const RewardsScreen()),
              buildListTile(context, icon: Icons.flag, iconColor: Colors.amber.shade300, title: 'Objetivos', destination: const ObjectivesScreen()),
            ],
          ),
          const Divider(),

          // Configuración Section
          ExpansionTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: Text('Configuración', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            children: <Widget>[
               buildListTile(context, icon: Icons.pie_chart, iconColor: Colors.blueGrey, title: 'Metas Calóricas', destination: const CaloricGoalsScreen()),
               buildListTile(context, icon: Icons.monitor_weight, iconColor: Colors.blueGrey, title: 'Objetivos de Peso', destination: const WeightGoalsScreen()),
               buildListTile(context, icon: Icons.palette, iconColor: Colors.blueGrey, title: 'Temas', destination: const ThemeSettingsScreen()),
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

          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.lightBlue),
            title: Text('Acerca de', style: GoogleFonts.lato()),
            onTap: () {
                // Could show an about dialog
                 showAboutDialog(
                    context: context,
                    applicationName: 'FitTrack AI',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 Your Company',
                    children: <Widget>[
                       const Padding(
                         padding: EdgeInsets.only(top: 15),
                         child: Text('Una app para un estilo de vida saludable, creada con IA.'),
                       )
                    ],
                );
            },
          ),
        ],
      ),
    );
  }
}
