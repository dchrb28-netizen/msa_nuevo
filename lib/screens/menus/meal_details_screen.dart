import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/meal_nutrition_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealType;
  final DateTime date;

  const MealDetailScreen({
    super.key,
    required this.mealType,
    required this.date,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  MealNutritionInfo? _nutrition;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNutrition();
  }

  Future<void> _loadNutrition() async {
    final mealPlanProvider = Provider.of<MealPlanProvider>(context, listen: false);
    final mealText = mealPlanProvider.getMealTextForDay(widget.date, widget.mealType);
    if (mealText.isEmpty) {
      setState(() {
        _nutrition = null;
        _loading = false;
      });
      return;
    }

    final info = await MealNutritionService.getNutritionForMeal(mealText);
    if (!mounted) return;
    setState(() {
      _nutrition = info;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanProvider = Provider.of<MealPlanProvider>(context);
    final mealText = mealPlanProvider.getMealTextForDay(widget.date, widget.mealType);
    final formattedDate = DateFormat('EEEE, d MMMM', 'es_ES').format(widget.date);
    final isCompleted = mealPlanProvider.getPlanForDay(widget.date)[widget.mealType]?.isCompleted ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealType),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.mealType,
                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(isCompleted ? 'Consumida' : 'Pendiente', style: GoogleFonts.lato(color: isCompleted ? Colors.green : Colors.orange)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                      onPressed: () {
                        mealPlanProvider.toggleMealCompletion(widget.date, widget.mealType);
                        // refresh nutrition if needed
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            Text('Descripción', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: mealText.isNotEmpty
                  ? Text(mealText, style: GoogleFonts.lato(fontSize: 15, height: 1.4))
                  : Text('No se ha añadido descripción. Edita en el Planificador Semanal.', style: GoogleFonts.lato(fontStyle: FontStyle.italic, color: Colors.grey)),
            ),

            const SizedBox(height: 16),

            Text('Información Nutricional', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _loading
                ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                : _nutrition != null
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_nutrition!.calories.toStringAsFixed(0)} kcal', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 6),
                                  Tooltip(
                                    message: 'Proteínas',
                                    child: Row(
                                      children: [
                                        const Text('🥩 ', style: TextStyle(fontSize: 16)),
                                        Text('${_nutrition!.protein.toStringAsFixed(0)} g', style: GoogleFonts.lato()),
                                      ],
                                    ),
                                  ),
                                  Tooltip(
                                    message: 'Carbohidratos',
                                    child: Row(
                                      children: [
                                        const Text('🍞 ', style: TextStyle(fontSize: 16)),
                                        Text('${_nutrition!.carbs.toStringAsFixed(0)} g', style: GoogleFonts.lato()),
                                      ],
                                    ),
                                  ),
                                  Tooltip(
                                    message: 'Grasas',
                                    child: Row(
                                      children: [
                                        const Text('🧈 ', style: TextStyle(fontSize: 16)),
                                        Text('${_nutrition!.fat.toStringAsFixed(0)} g', style: GoogleFonts.lato()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              _nutrition!.isFromApi ? const Icon(Icons.cloud_done) : const Icon(Icons.storage),
                            ],
                          ),
                        ),
                      )
                    : Text('No se pudo obtener información nutricional para esta descripción.', style: GoogleFonts.lato(color: Colors.grey)),

            const Spacer(),
            Text('Edición disponible en: Planificador Semanal', style: GoogleFonts.lato(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
