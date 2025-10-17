import 'package:flutter/material.dart';
import 'package:myapp/widgets/ui/screen_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: const Stack(
        children: [
          ScreenBackground(screenName: 'configuracion'),
          Center(
            child: Text('Aquí podrás configurar la aplicación.'),
          ),
        ],
      ),
    );
  }
}
