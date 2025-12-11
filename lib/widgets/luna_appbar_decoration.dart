import 'package:flutter/material.dart';

/// Widget decorativo de Luna para usar en el AppBar
/// Muestra una versión pequeña de Luna en la esquina del AppBar
class LunaAppBarDecoration extends StatelessWidget {
  final LunaType type;
  final double size;
  final double opacity;

  const LunaAppBarDecoration({
    super.key,
    required this.type,
    this.size = 40,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagePath = _getImagePath(isDark);

    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          imagePath,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  String _getImagePath(bool isDark) {
    final suffix = isDark ? '_b.png' : '_w.png';
    final prefix = type.name;
    return 'assets/luna_png/luna_$prefix$suffix';
  }
}

/// Tipos de Luna disponibles para cada sección
enum LunaType {
  inicio,
  agua,
  ayuno,
  comida,
  configuracion,
  entrenamiento,
  lista,
  medida,
  menus,
  objetivos,
  perfil,
  progreso,
  recompensa,
  recordatorios,
  splash,
}
