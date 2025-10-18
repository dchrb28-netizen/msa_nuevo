import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final String lunaImagePath = isDarkMode 
        ? 'assets/luna_png/luna_logo_b.png' 
        : 'assets/luna_png/luna_logo_w.png';

    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de Salud Activa', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface.withAlpha(230),
              colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                Image.asset(lunaImagePath, height: 120),
                const SizedBox(height: 24),
                Text(
                  'Salud Activa',
                  style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Versión 1.0.0',
                  style: GoogleFonts.lato(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 32),
                Text(
                  'Tu compañero personal para una vida más saludable. Registra tus actividades, sigue tu progreso y alcanza tus metas con una interfaz diseñada para motivarte cada día.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 40),
                _buildSectionTitle(context, 'Construido con'),
                const SizedBox(height: 16),
                _buildTechnologyCard(context, 'Flutter', 'El framework de Google para crear hermosas apps, compiladas nativamente, desde una única base de código.', Icons.flutter_dash),
                 _buildTechnologyCard(context, 'Firebase', 'La plataforma de Google que nos ayuda a construir y ejecutar aplicaciones exitosas.', Icons.local_fire_department_outlined),
                _buildTechnologyCard(context, 'Google Fonts', 'Una librería de fuentes de código abierto para dar vida a nuestro diseño.', Icons.font_download_outlined),
                const SizedBox(height: 24),
                 Text(
                  '© 2024 Luna Arts. Todos los derechos reservados.',
                  style: GoogleFonts.lato(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget _buildTechnologyCard(BuildContext context, String title, String subtitle, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.lato()),
      ),
    );
  }
}
