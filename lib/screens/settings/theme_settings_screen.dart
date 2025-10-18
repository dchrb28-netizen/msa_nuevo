import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PantallaTemas extends StatelessWidget {
  const PantallaTemas({super.key});

  // Function to show the color picker dialog
  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: themeProvider.seedColor,
              onColorChanged: (Color color) {
                themeProvider.setSeedColor(color);
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hecho'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Theme Mode Selection ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Modo de Tema',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Tema oscuro'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
            secondary: Icon(
              themeProvider.themeMode == ThemeMode.dark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_system_daydream_outlined),
            title: const Text('Seguir la configuración del sistema'),
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
            trailing: themeProvider.themeMode == ThemeMode.system ? const Icon(Icons.check) : null,
          ),
          const Divider(height: 32),

          // --- Color Selection ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Color Principal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            title: const Text('Selecciona un color principal'),
            subtitle: const Text('Toca para abrir el selector de color'),
            trailing: CircleAvatar(
              backgroundColor: themeProvider.seedColor,
              radius: 15,
            ),
            onTap: () => _showColorPicker(context, themeProvider),
          ),
        ],
      ),
    );
  }
}
