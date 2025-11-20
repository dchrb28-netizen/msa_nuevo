import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/services/achievement_service.dart'; // Importar AchievementService
import 'package:provider/provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

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
              achievementService.updateProgress('exp_theme_change', 1); // Logro por cambiar el tema
            },
            showSelectedIcon: true,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Text('Paleta de Colores', style: textTheme.titleLarge),
          const SizedBox(height: 12),

          // Nueva lista de temas
          ListView( 
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: themeProvider.availableThemes.entries.map((entry) {
              final String themeName = entry.key;
              final Color themeColor = entry.value;
              final bool isSelected = themeProvider.seedColor == themeColor;

              return Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected 
                      ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: themeColor,
                  ),
                  title: Text(themeName),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded) : null,
                  onTap: () {
                    themeProvider.setSeedColor(themeColor);
                    achievementService.updateProgress('exp_theme_change', 1); // Logro por cambiar el tema
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
