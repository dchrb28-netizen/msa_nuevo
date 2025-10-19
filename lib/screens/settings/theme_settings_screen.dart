import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personaliza la Apariencia',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
              ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.wb_sunny)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro'), icon: Icon(Icons.nightlight_round)),
              ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.auto_awesome)),
            ],
            selected: {themeProvider.themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              themeProvider.setThemeMode(newSelection.first);
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

          // Color picker
          ColorPicker(
            color: themeProvider.seedColor,
            onColorChanged: (Color color) {
              themeProvider.setSeedColor(color);
            },
            width: 44,
            height: 44,
            borderRadius: 22,
            heading: Text(
              'Selecciona un color',
              style: textTheme.titleMedium,
            ),
            subheading: Text(
              'Arrastra para ajustar la tonalidad',
              style: textTheme.bodySmall,
            ),
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.both: false,
              ColorPickerType.primary: true,
              ColorPickerType.accent: false,
              ColorPickerType.bw: false,
              ColorPickerType.custom: false,
              ColorPickerType.wheel: true,
            },
            pickerTypeLabels: const <ColorPickerType, String>{
              ColorPickerType.primary: 'Primarios',
              ColorPickerType.wheel: 'Rueda de Color',
            },
          ),
        ],
      ),
    );
  }
}
