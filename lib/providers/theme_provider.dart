import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final String keyThemeMode = "theme_mode";
  final String keySeedColor = "seed_color";

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = const Color(0xFF00BCD4); // Default celeste (Cyan)

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  // Mapa de colores con nombres para la UI
  final Map<String, Color> _availableThemes = {
    'Celeste': const Color(0xFF00BCD4),
    'Océano': Colors.blue,
    'Zen': const Color(0xFF2E7D32),
    'Naturaleza': Colors.green,
    'Fuego': Colors.red,
    'Lavanda': Colors.purple,
    'Atardecer': Colors.orange,
    'Caribe': Colors.teal,
  };

  Map<String, Color> get availableThemes => _availableThemes;

  ThemeProvider() {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt(keyThemeMode);
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
      print('🎨 ThemeProvider cargado: themeMode = $themeModeIndex ($_themeMode)');
    } else {
      print('🎨 ThemeProvider: No hay themeMode guardado, usando default (System)');
    }

    final seedColorValue = prefs.getInt(keySeedColor);
    if (seedColorValue != null) {
      _seedColor = Color(seedColorValue);
      print('🎨 ThemeProvider cargado: seedColor = $seedColorValue');
    } else {
      print('🎨 ThemeProvider: No hay seedColor guardado, usando default (Cyan)');
    }

    print('🎨 [INICIO] ThemeProvider inicializado: mode=$_themeMode, color=${_seedColor.value}');
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('💾 Guardando tema: ${_themeMode.index}');
    await prefs.setInt(keyThemeMode, _themeMode.index);
    // ignore: deprecated_member_use
    print('💾 Guardando color: ${_seedColor.value}');
    await prefs.setInt(keySeedColor, _seedColor.value);
    print('✅ Preferencias guardadas en SharedPreferences');
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    print('🎨 Cambiando tema de $_themeMode a $mode');
    _themeMode = mode;
    notifyListeners();
    await _savePreferences();
    print('🎨 Tema guardado: $mode (index: ${mode.index})');
  }

  Future<void> setSeedColor(Color color) async {
    if (color == _seedColor) return;
    print('🎨 Cambiando color a $color');
    _seedColor = color;
    notifyListeners();
    await _savePreferences();
    print('🎨 Color guardado: ${color.value}');
  }
}
