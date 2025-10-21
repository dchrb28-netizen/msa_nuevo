
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/widgets/dashboard/circular_progress_card.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/user_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildWelcomeHeader(context),
        const SizedBox(height: 24),
        _buildCaloriesCard(),
        const SizedBox(height: 24),
        _buildWeightProgressCard(),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    // Use a Consumer to listen directly to the UserProvider for changes
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha((255 * 0.3).round()),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white70,
                backgroundImage: (user?.profileImageBytes != null)
                    ? MemoryImage(user!.profileImageBytes!)
                    : null,
                child: (user?.profileImageBytes == null)
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Invitado',
                      style: GoogleFonts.montserrat(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca para crear o editar tu perfil',
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha((255 * 0.8).round())),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCaloriesCard() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        final now = DateTime.now();
        final dailyLogs = box.values.where((log) =>
            log.timestamp.year == now.year &&
            log.timestamp.month == now.month &&
            log.timestamp.day == now.day);
        final totalCalories = dailyLogs.fold<double>(
            0, (sum, log) => sum + (log.food.calories * log.quantity / 100));
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

  Widget _buildWeightProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progreso de Peso',
                style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable:
                  Hive.box<BodyMeasurement>('body_measurements').listenable(),
              builder: (context, Box<BodyMeasurement> box, _) {
                if (box.values.length < 2) {
                  return const Text(
                      'No hay suficientes datos para mostrar el progreso.');
                }
                final lastTwo = box.values.toList()
                  ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
                final last = lastTwo.last;
                final secondLast = lastTwo[lastTwo.length - 2];
                final difference = (last.weight ?? 0) - (secondLast.weight ?? 0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeightStat(context, 'Último', last.weight, 'kg'),
                    _buildWeightStat(context, 'Cambio', difference, 'kg',
                        showSign: true),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightStat(BuildContext context, String label, double? value, String unit,
      {bool showSign = false}) {
    if (value == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;

    final valueString = (showSign && value > 0)
        ? '+${value.toStringAsFixed(1)}'
        : value.toStringAsFixed(1);
    final valueColor = !showSign
        ? colorScheme.onSurface
        : (value > 0 ? colorScheme.error : Colors.green);

    return Column(
      children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 16, color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text('$valueString $unit',
            style: GoogleFonts.montserrat(
                fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
