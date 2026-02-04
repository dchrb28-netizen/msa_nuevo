                                                                                                                                                                                                                                                          import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:myapp/widgets/body_measurement_form.dart';
import 'package:provider/provider.dart';

class BodyMeasurementTodayView extends StatelessWidget {
  const BodyMeasurementTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildWeightGoalSummary(context),
        const SizedBox(height: 28),
        const Text(
          'Registra tus medidas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const BodyMeasurementForm(),
        const SizedBox(height: 28),
        const Text(
          'Última medición de hoy',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildLastMeasurementCard(context),
      ],
    );
  }

  Widget _buildWeightGoalSummary(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final weightGoal = user?.weightGoal;
        final initialWeight = user?.weight;
        final theme = Theme.of(context);

        if (weightGoal == null || weightGoal <= 0) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder(
          valueListenable: Hive.box<BodyMeasurement>(
            'body_measurements',
          ).listenable(),
          builder: (context, Box<BodyMeasurement> box, _) {
            final measurementsWithWeight = box.values
                .where((m) => m.weight != null && m.weight! > 0)
                .toList();
            BodyMeasurement? lastMeasurementWithWeight;
            if (measurementsWithWeight.isNotEmpty) {
              measurementsWithWeight.sort(
                (a, b) => b.timestamp.compareTo(a.timestamp),
              );
              lastMeasurementWithWeight = measurementsWithWeight.first;
            }

            final lastWeight =
                lastMeasurementWithWeight?.weight ?? initialWeight;

            if (lastWeight == null || lastWeight <= 0) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                      theme.colorScheme.primaryContainer.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.scale,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Comienza tu Viaje',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registra tu primer peso',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final progress = ((lastWeight ?? 0) - (weightGoal ?? 0)).abs();
            final isGoalReached = (lastWeight ?? 0) <= (weightGoal ?? 0);
            final remainingText = isGoalReached
              ? 'Meta alcanzada'
              : 'Faltan ${progress.toStringAsFixed(1)} kg';

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.4),
                    theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.25),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.scale,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peso actual',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '${lastWeight?.toStringAsFixed(1)} kg',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Objetivo: ${weightGoal?.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          remainingText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isGoalReached
                                ? Colors.green
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLastMeasurementCard(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<BodyMeasurement>(
        'body_measurements',
      ).listenable(),
      builder: (context, Box<BodyMeasurement> box, _) {
        final today = DateTime.now();
        final todaysMeasurements = box.values.where((m) {
          return m.timestamp.year == today.year &&
              m.timestamp.month == today.month &&
              m.timestamp.day == today.day;
        }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (todaysMeasurements.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.05),
                  Colors.grey.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.sentiment_very_satisfied_outlined,
                    size: 40,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aún no has registrado medidas hoy',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final lastMeasurement = todaysMeasurements.first;
        final theme = Theme.of(context);
        final timeService = Provider.of<TimeFormatService>(context);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.2),
                theme.colorScheme.secondaryContainer.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Medición a las ${timeService.formatTime(lastMeasurement.timestamp)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (lastMeasurement.weight != null)
                _buildMeasurementRow(
                  context,
                  'Peso',
                  '${lastMeasurement.weight} kg',
                  Icons.scale,
                  Colors.orange,
                ),
              if (lastMeasurement.chest != null)
                _buildMeasurementRow(
                  context,
                  'Pecho',
                  '${lastMeasurement.chest} cm',
                  Icons.fitness_center,
                  Colors.red,
                ),
              if (lastMeasurement.arm != null)
                _buildMeasurementRow(
                  context,
                  'Brazo',
                  '${lastMeasurement.arm} cm',
                  Icons.front_hand,
                  Colors.pink,
                ),
              if (lastMeasurement.waist != null)
                _buildMeasurementRow(
                  context,
                  'Cintura',
                  '${lastMeasurement.waist} cm',
                  Icons.straighten,
                  Colors.blue,
                ),
              if (lastMeasurement.hips != null)
                _buildMeasurementRow(
                  context,
                  'Caderas',
                  '${lastMeasurement.hips} cm',
                  Icons.crop_free,
                  Colors.purple,
                ),
              if (lastMeasurement.thigh != null)
                _buildMeasurementRow(
                  context,
                  'Muslo',
                  '${lastMeasurement.thigh} cm',
                  Icons.unfold_more_outlined,
                  Colors.green,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeasurementRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
