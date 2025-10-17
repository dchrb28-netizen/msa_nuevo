import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/widgets/ui/screen_background.dart';
import 'package:myapp/widgets/dashboard/circular_progress_card.dart';
import 'package:myapp/widgets/dashboard/quick_action_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          const ScreenBackground(screenName: 'inicio'),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              _buildCaloriesCard(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildWeightProgressCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hola de nuevo,', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[600])),
        Text('¿Listo para Conquistar tu Día?', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCaloriesCard() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        final dailyLogs = box.values.where((log) => DateUtils.isSameDay(log.timestamp, DateTime.now()));
        final totalCalories = dailyLogs.fold<double>(0, (sum, log) => sum + (log.food.calories * log.quantity / 100));
        // TODO: This should come from user settings
        const caloricGoal = 2000; 

        return CircularProgressCard(
          title: 'Calorías Consumidas',
          progress: totalCalories / caloricGoal,
          centerText: '${totalCalories.toInt()}kcal',
          primaryColor: Colors.orange,
          backgroundColor: Colors.orange.withAlpha((255 * 0.2).round()),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        QuickActionButton(icon: Icons.add, label: 'Añadir Comida', onTap: () => Navigator.of(context).pushNamed('/food-log')),
        QuickActionButton(icon: Icons.directions_run, label: 'Registrar Ejercicio', onTap: () => Navigator.of(context).pushNamed('/exercise-log')),
        QuickActionButton(icon: Icons.straighten, label: 'Medir Cuerpo', onTap: () => Navigator.of(context).pushNamed('/body-measurement')),
        QuickActionButton(icon: Icons.insights, label: 'Ver Progreso', onTap: () => Navigator.of(context).pushNamed('/progress')),
      ],
    );
  }
  
  Widget _buildWeightProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progreso de Peso', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: Hive.box<BodyMeasurement>('body_measurements').listenable(),
              builder: (context, Box<BodyMeasurement> box, _) {
                if (box.values.length < 2) {
                  return const Text('No hay suficientes datos para mostrar el progreso.');
                }
                final lastTwo = box.values.toList()..sort((a,b) => a.timestamp.compareTo(b.timestamp));
                final last = lastTwo.last;
                final secondLast = lastTwo[lastTwo.length - 2];
                final difference = (last.weight ?? 0) - (secondLast.weight ?? 0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeightStat('Último', last.weight, 'kg'),
                    _buildWeightStat('Cambio', difference, 'kg', showSign: true),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightStat(String label, double? value, String unit, {bool showSign = false}) {
    if (value == null) return const SizedBox.shrink();

    final valueString = (showSign && value > 0) ? '+${value.toStringAsFixed(1)}' : value.toStringAsFixed(1);
    final valueColor = !showSign ? Colors.black : (value > 0 ? Colors.red : Colors.green);

    return Column(
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text('$valueString $unit', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
