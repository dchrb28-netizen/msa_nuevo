import 'package:flutter/material.dart';

/// Widget para mostrar GIFs de ejercicios con mejor manejo de errores
class ExerciseGifWidget extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final BoxFit fit;

  const ExerciseGifWidget({
    super.key,
    this.imageUrl,
    this.height = 200,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        height: height,
        width: double.infinity,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cargando...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error cargando GIF: $error');
          return _buildPlaceholder(context);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Demostración no disponible',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
