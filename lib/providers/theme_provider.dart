import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = const Color(0xFF26A69A); // Teal
  // Nuevo color específico para la AppBar y el Drawer
  Color _appBarColor = const Color(0xFF673AB7); // Un morado vibrante

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  Color get appBarColor => _appBarColor;

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setSeedColor(Color color) {
    _seedColor = color;
    notifyListeners();
  }
  
  // Función para cambiar el color de la barra de la app y el menú
  void setAppBarColor(Color color) {
    _appBarColor = color;
    notifyListeners();
  }

  ThemeData get lightTheme => _createTheme(Brightness.light);
  ThemeData get darkTheme => _createTheme(Brightness.dark);

  ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      // El fondo del Drawer usará el color de la AppBar
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark ? colorScheme.surface : _appBarColor, // En modo oscuro, un fondo más sutil
      ),
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      appBarTheme: AppBarTheme(
        // Color de la barra de la aplicación fijo y vibrante
        backgroundColor: _appBarColor, 
        // Color de texto que contrasta
        foregroundColor: Colors.white, 
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24, 
          fontWeight: FontWeight.bold,
          color: Colors.white // Aseguramos el color del título
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Color para iconos en la AppBar
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
