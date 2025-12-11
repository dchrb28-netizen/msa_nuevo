import 'package:flutter/material.dart';

class WatermarkImage extends StatelessWidget {
  final String imageName;

  const WatermarkImage({super.key, required this.imageName});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final imagePath =
        'assets/luna_png/luna_${imageName}_${isDarkMode ? 'b' : 'w'}.png';

    return Opacity(
      opacity: 0.05, // Adjust opacity for watermark effect
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
