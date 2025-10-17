import 'package:flutter/material.dart';

class ScreenBackground extends StatelessWidget {
  final String screenName;

  const ScreenBackground({
    super.key,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final imageName = 'luna_${screenName}_${isDarkMode ? 'w' : 'b'}.png';
    final imagePath = 'assets/luna_png/$imageName';

    return Positioned.fill(
      child: Opacity(
        opacity: 0.05, // Opacidad sutil para el efecto de marca de agua
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          alignment: Alignment.bottomRight, // Posicionar la imagen abajo a la derecha
          errorBuilder: (context, error, stackTrace) {
            return Container(); // No mostrar nada si la imagen no se encuentra
          },
        ),
      ),
    );
  }
}
