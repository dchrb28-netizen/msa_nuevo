import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircularProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final String centerText;
  final Color primaryColor;
  final Color backgroundColor;

  const CircularProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.centerText,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 12.0,
              percent: progress.clamp(0.0, 1.0),
              center: Text(
                centerText,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: primaryColor,
              backgroundColor: backgroundColor,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }
}
