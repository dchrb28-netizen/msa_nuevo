import 'package:flutter/material.dart';
import 'package:myapp/screens/settings/theme_settings_screen.dart';
import 'package:myapp/widgets/ui/screen_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Stack(
        children: [
          const ScreenBackground(screenName: 'configuracion'),
          ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Tema'),
                subtitle: const Text('Cambia la apariencia de la aplicación'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaTemas(),
                    ),
                  );
                },
              ),
              // Agrega más opciones de configuración aquí
            ],
          ),
        ],
      ),
    );
  }
}
