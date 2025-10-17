import 'dart:math';
import 'package:flutter/material.dart';

class AmbientBubbleAnimation extends StatefulWidget {
  const AmbientBubbleAnimation({super.key});

  @override
  State<AmbientBubbleAnimation> createState() => _AmbientBubbleAnimationState();
}

class _AmbientBubbleAnimationState extends State<AmbientBubbleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slower, more ambient feel
    )..repeat();

    _bubbles = List.generate(25, (index) {
      final random = Random();
      return Bubble(
        size: random.nextDouble() * 8 + 2, // Smaller bubbles
        speed: random.nextDouble() * 20 + 5, // Slower speed
        initialPosition: Offset(
          random.nextDouble() * 400, // Assuming a max width
          random.nextDouble() * 300, // Start from anywhere in the aquarium
        ),
        color: Colors.white.withAlpha((random.nextDouble() * 0.15 + 0.05 * 255).toInt()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BubblePainter(bubbles: _bubbles, progress: _controller.value, size: MediaQuery.of(context).size),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double progress;
  final Size size;

  BubblePainter({required this.bubbles, required this.progress, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final paint = Paint()..color = bubble.color;
      // Loop the bubble's vertical position
      final verticalProgress = (progress + bubble.initialPosition.dy / size.height) % 1.0;

      final offset = Offset(
        bubble.initialPosition.dx,
        size.height - (verticalProgress * (size.height + bubble.size)),
      );
      canvas.drawCircle(offset, bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class Bubble {
  final double size;
  final double speed;
  final Offset initialPosition;
  final Color color;

  Bubble({
    required this.size,
    required this.speed,
    required this.initialPosition,
    required this.color,
  });
}
