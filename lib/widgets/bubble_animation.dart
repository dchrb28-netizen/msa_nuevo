import 'dart:math';
import 'package:flutter/material.dart';

class BubbleAnimation extends StatefulWidget {
  const BubbleAnimation({super.key});

  @override
  State<BubbleAnimation> createState() => _BubbleAnimationState();
}

class _BubbleAnimationState extends State<BubbleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _bubbles = List.generate(40, (index) {
      final random = Random();
      return Bubble(
        size: random.nextDouble() * 20 + 5,
        speed: random.nextDouble() * 50 + 20,
        initialPosition: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 100 + 250,
        ),
        color: Colors.white.withAlpha((random.nextDouble() * 128 + 51).toInt()),
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
          painter: BubblePainter(bubbles: _bubbles, progress: _controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double progress;

  BubblePainter({required this.bubbles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      // FIX: Use toARGB32() to get alpha component, avoiding deprecated getters.
      final int originalAlpha = (bubble.color.toARGB32() >> 24) & 0xFF;
      final double newAlphaValue = originalAlpha * (1 - progress);
      final paint = Paint()..color = bubble.color.withAlpha(newAlphaValue.toInt().clamp(0, 255));
      
      final offset = Offset(
        bubble.initialPosition.dx,
        bubble.initialPosition.dy - (progress * bubble.speed * 5),
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
