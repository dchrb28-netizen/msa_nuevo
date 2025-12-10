import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:provider/provider.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  bool _showAdvancedPicker = false;

  // Paleta de colores predefinidos (Material Design 3)
  static const List<Color> _presetColors = [
    Color(0xFF6750A4), // Purple (default Material)
    Color(0xFFD32F2F), // Red
    Color(0xFFC2185B), // Pink
    Color(0xFF7B1FA2), // Deep Purple
    Color(0xFF512DA8), // Indigo
    Color(0xFF1976D2), // Blue
    Color(0xFF0288D1), // Light Blue
    Color(0xFF0097A7), // Cyan
    Color(0xFF00796B), // Teal
    Color(0xFF388E3C), // Green
    Color(0xFF689F38), // Light Green
    Color(0xFFAFB42B), // Lime
    Color(0xFFFBC02D), // Yellow
    Color(0xFFFFA000), // Amber
    Color(0xFFF57C00), // Orange
    Color(0xFFE64A19), // Deep Orange
    Color(0xFF5D4037), // Brown
    Color(0xFF616161), // Grey
    Color(0xFF455A64), // Blue Grey
    Color(0xFF000000), // Black
  ];

  void _showColorPickerDialog(
      BuildContext context, ThemeProvider themeProvider, AchievementService achievementService) {
    Color pickerColor = themeProvider.seedColor;
    final Color originalColor = themeProvider.seedColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Elige un color'),
                  IconButton(
                    icon: Icon(_showAdvancedPicker ? Icons.palette : Icons.tune),
                    onPressed: () {
                      setDialogState(() {
                        _showAdvancedPicker = !_showAdvancedPicker;
                      });
                    },
                    tooltip: _showAdvancedPicker ? 'Paleta simple' : 'Selector avanzado',
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Preview del color con ejemplos
                      _buildColorPreview(pickerColor, context),
                      const SizedBox(height: 24),
                      
                      if (!_showAdvancedPicker) ...[
                        // Paleta de colores predefinidos
                        const Text(
                          'Colores populares',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPresetColorGrid(
                          pickerColor,
                          (color) {
                            setDialogState(() {
                              pickerColor = color;
                              themeProvider.setSeedColor(color);
                            });
                          },
                        ),
                      ] else ...[
                        // Selector avanzado HSV
                        const Text(
                          'Selector personalizado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ColorPicker(
                          pickerColor: pickerColor,
                          onColorChanged: (Color color) {
                            setDialogState(() {
                              pickerColor = color;
                              themeProvider.setSeedColor(color);
                            });
                          },
                          pickerAreaHeightPercent: 0.7,
                          enableAlpha: false,
                          displayThumbColor: true,
                          paletteType: PaletteType.hslWithHue,
                          labelTypes: const [],
                          colorPickerWidth: 280,
                          portraitOnly: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    themeProvider.setSeedColor(originalColor);
                    setState(() {
                      _showAdvancedPicker = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Guardar'),
                  onPressed: () {
                    themeProvider.setSeedColor(pickerColor);
                    achievementService.updateProgress('exp_theme_change', 1);
                    setState(() {
                      _showAdvancedPicker = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorPreview(Color color, BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Vista previa',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón ejemplo
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Botón'),
              ),
              // Chip ejemplo
              Chip(
                label: const Text('Chip'),
                backgroundColor: colorScheme.primaryContainer,
                labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Card ejemplo
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tarjeta de ejemplo',
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetColorGrid(Color selectedColor, Function(Color) onColorSelected) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _presetColors.length,
      itemBuilder: (context, index) {
        final color = _presetColors[index];
        final isSelected = color.value == selectedColor.value;

        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 3,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      },
    );
  }

  String _getColorName(Color color) {
    final colorMap = {
      0xFF6750A4: 'Púrpura Material',
      0xFFD32F2F: 'Rojo',
      0xFFC2185B: 'Rosa',
      0xFF7B1FA2: 'Púrpura Profundo',
      0xFF512DA8: 'Índigo',
      0xFF1976D2: 'Azul',
      0xFF0288D1: 'Azul Claro',
      0xFF0097A7: 'Cian',
      0xFF00796B: 'Verde Azulado',
      0xFF388E3C: 'Verde',
      0xFF689F38: 'Verde Lima',
      0xFFAFB42B: 'Lima',
      0xFFFBC02D: 'Amarillo',
      0xFFFFA000: 'Ámbar',
      0xFFF57C00: 'Naranja',
      0xFFE64A19: 'Naranja Profundo',
      0xFF5D4037: 'Marrón',
      0xFF616161: 'Gris',
      0xFF455A64: 'Gris Azulado',
      0xFF000000: 'Negro',
    };

    final colorValue = color.value;
    if (colorMap.containsKey(colorValue)) {
      return colorMap[colorValue]!;
    }
    
    // Para colores personalizados, mostrar código hex
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final achievementService = Provider.of<AchievementService>(context, listen: false);
    final timeFormatService = Provider.of<TimeFormatService>(context);
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
          
          // Tarjeta principal del color actual
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            child: InkWell(
              onTap: () {
                _showColorPickerDialog(context, themeProvider, achievementService);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.seedColor.withValues(alpha: 0.1),
                      themeProvider.seedColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: themeProvider.seedColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.seedColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.palette,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Color principal actual',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toca para personalizar',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getColorName(themeProvider.seedColor),
                            style: TextStyle(
                              color: themeProvider.seedColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Accesos rápidos a colores predefinidos
          const SizedBox(height: 16),
          const Text(
            'Accesos rápidos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final quickColors = [
                  const Color(0xFF6750A4), // Purple
                  const Color(0xFF1976D2), // Blue
                  const Color(0xFF388E3C), // Green
                  const Color(0xFFD32F2F), // Red
                  const Color(0xFFF57C00), // Orange
                  const Color(0xFFC2185B), // Pink
                  const Color(0xFF00796B), // Teal
                  const Color(0xFF7B1FA2), // Deep Purple
                ];
                final color = quickColors[index];
                final isSelected = color.value == themeProvider.seedColor.value;

                return GestureDetector(
                  onTap: () {
                    themeProvider.setSeedColor(color);
                    achievementService.updateProgress('exp_theme_change', 1);
                  },
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 3,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Text('Formato de Hora', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  value: timeFormatService.use24HourFormat,
                  onChanged: (value) {
                    timeFormatService.setTimeFormat(value);
                  },
                  title: const Text('Formato de 24 horas'),
                  subtitle: Text(
                    timeFormatService.use24HourFormat
                        ? 'Ejemplo: 14:30'
                        : 'Ejemplo: 2:30 PM',
                  ),
                  secondary: Icon(
                    timeFormatService.use24HourFormat
                        ? Icons.access_time
                        : Icons.schedule,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
