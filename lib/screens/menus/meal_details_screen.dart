import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:provider/provider.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealType;
  final DateTime date;

  const MealDetailScreen({
    super.key,
    required this.mealType,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final mealPlanProvider = Provider.of<MealPlanProvider>(context);
    final mealText = mealPlanProvider.getMealTextForDay(date, mealType);
    final formattedDate = DateFormat('EEEE, d MMMM', 'es_ES').format(date);

    return Scaffold(
      appBar: AppBar(
        // title removed
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Descripción de la Comida:',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(
                        26,
                      ), // Updated from withOpacity
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: mealText.isNotEmpty
                      ? SingleChildScrollView(
                          child: Text(
                            mealText,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.lato(
                              fontSize: 17,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        )
                      : Text(
                          'No se ha añadido ninguna descripción para esta comida.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 17,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
