import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:provider/provider.dart';

class BodyMeasurementHistoryView extends StatelessWidget {
  const BodyMeasurementHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final formattedDate = DateFormat.yMMMEd('es').format(today);
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.outlineVariant,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historial de Mediciones',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildFullHistory(context),
      ],
    );
  }

  Widget _buildFullHistory(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return ValueListenableBuilder(
      valueListenable: Hive.box<BodyMeasurement>(
        'body_measurements',
      ).listenable(),
      builder: (context, Box<BodyMeasurement> box, _) {
        final allMeasurements = box.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (allMeasurements.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.straighten,
                    size: 64,
                    color: colors.primary.withAlpha(77),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin mediciones registradas',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comienza a registrar tus medidas',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Agrupar mediciones por día
        final Map<DateTime, List<BodyMeasurement>> groupedMeasurements = {};
        for (var m in allMeasurements) {
          final day = DateTime(
            m.timestamp.year,
            m.timestamp.month,
            m.timestamp.day,
          );
          if (groupedMeasurements[day] == null) {
            groupedMeasurements[day] = [];
          }
          groupedMeasurements[day]!.add(m);
        }

        final sortedDays = groupedMeasurements.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDays.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final day = sortedDays[index];
            final measurementsForDay = groupedMeasurements[day]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMEd('es').format(day),
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ...measurementsForDay.map(
                  (measurement) => Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 18,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Medición a las ${Provider.of<TimeFormatService>(context).formatTime(measurement.timestamp)}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        if (measurement.weight != null)
                          _buildMeasurementRow(
                            context,
                            'Peso',
                            '${measurement.weight} kg',
                            Icons.scale,
                          ),
                        if (measurement.chest != null)
                          _buildMeasurementRow(
                            context,
                            'Pecho',
                            '${measurement.chest} cm',
                            Icons.accessibility,
                          ),
                        if (measurement.arm != null)
                          _buildMeasurementRow(
                            context,
                            'Brazo',
                            '${measurement.arm} cm',
                            Icons.fitness_center,
                          ),
                        if (measurement.waist != null)
                          _buildMeasurementRow(
                            context,
                            'Cintura',
                            '${measurement.waist} cm',
                            Icons.monitor_weight,
                          ),
                        if (measurement.hips != null)
                          _buildMeasurementRow(
                            context,
                            'Caderas',
                            '${measurement.hips} cm',
                            Icons.accessibility_new,
                          ),
                        if (measurement.thigh != null)
                          _buildMeasurementRow(
                            context,
                            'Muslo',
                            '${measurement.thigh} cm',
                            Icons.straighten,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMeasurementRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
    TextStyle? valueStyle,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: colors.primary.withAlpha(179),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color ?? colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
