import 'package:flutter/material.dart';

/// Widget de marca de agua con la mascota Luna
/// Muestra una imagen semitransparente que se adapta al tema
class LunaWatermark extends StatelessWidget {
  /// Tipo de imagen de Luna a mostrar
  final LunaType type;
  
  /// Opacidad de la marca de agua (0.0 a 1.0)
  final double opacity;
  
  /// Tamaño de la imagen
  final double size;
  
  /// Alineación de la marca de agua
  final Alignment alignment;

  const LunaWatermark({
    super.key,
    required this.type,
    this.opacity = 0.15,
    this.size = 200,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagePath = _getImagePath(type, isDark);

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Si falla la carga, no mostrar nada
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  String _getImagePath(LunaType type, bool isDark) {
    final suffix = isDark ? '_b.png' : '_w.png';
    final prefix = 'assets/luna_png/luna_';
    
    switch (type) {
      case LunaType.agua:
        return '${prefix}agua$suffix';
      case LunaType.ayuno:
        return '${prefix}ayuno$suffix';
      case LunaType.comida:
        return '${prefix}comida$suffix';
      case LunaType.configuracion:
        return '${prefix}configuracion$suffix';
      case LunaType.entrenamiento:
        return '${prefix}entrenamiento$suffix';
      case LunaType.inicio:
        return '${prefix}inicio$suffix';
      case LunaType.lista:
        return '${prefix}lista$suffix';
      case LunaType.medida:
        return '${prefix}medida$suffix';
      case LunaType.menus:
        return '${prefix}menús$suffix';
      case LunaType.objetivos:
        return '${prefix}objetivos$suffix';
      case LunaType.perfil:
        return '${prefix}perfil$suffix';
      case LunaType.progreso:
        return '${prefix}progreso$suffix';
      case LunaType.recompensa:
        return '${prefix}recompensa$suffix';
      case LunaType.recordatorios:
        return '${prefix}recordatorios$suffix';
      case LunaType.splash:
        return '${prefix}splash$suffix';
    }
  }
}

/// Tipos de imágenes de Luna disponibles
enum LunaType {
  agua,
  ayuno,
  comida,
  configuracion,
  entrenamiento,
  inicio,
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
