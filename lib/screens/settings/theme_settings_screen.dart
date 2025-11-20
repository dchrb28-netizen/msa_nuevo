import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:provider/provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  void _showColorPickerDialog(
      BuildContext context, ThemeProvider themeProvider, AchievementService achievementService) {
    Color pickerColor = themeProvider.seedColor;
    final Color originalColor = themeProvider.seedColor; // Guardar el color original

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Elige un color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                // Actualización en tiempo real
                themeProvider.setSeedColor(color);
                pickerColor = color; // Actualizar el color del picker
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
              labelTypes: const [],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                // Revertir al color original si se cancela
                themeProvider.setSeedColor(originalColor);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () {
                // Guardar el color seleccionado y registrar el logro
                themeProvider.setSeedColor(pickerColor);
                achievementService.updateProgress('exp_theme_change', 1);
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final achievementService = Provider.of<AchievementService>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personaliza la Apariencia',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elige tu modo de tema preferido y el color principal de la aplicación para una experiencia a tu medida.',
          ),
          const SizedBox(height: 24),
          Text('Modo de Tema', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const <ButtonSegment<ThemeMode>>[
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Claro'),
                icon: Icon(Icons.wb_sunny),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Oscuro'),
                icon: Icon(Icons.nightlight_round),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Sistema'),
                icon: Icon(Icons.auto_awesome),
              ),
            ],
            selected: {themeProvider.themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              themeProvider.setThemeMode(newSelection.first);
              achievementService.updateProgress('exp_theme_change', 1);
            },
            showSelectedIcon: true,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Text('Color Principal', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: () {
                _showColorPickerDialog(context, themeProvider, achievementService);
              },
              leading: CircleAvatar(
                backgroundColor: themeProvider.seedColor,
                radius: 20,
              ),
              title: const Text('Color principal actual'),
              subtitle: const Text('Toca para seleccionar un nuevo color'),
              trailing: const Icon(Icons.colorize),
            ),
          )
        ],
      ),
    );
  }
}
